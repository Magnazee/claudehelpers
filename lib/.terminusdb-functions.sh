#!/bin/bash

TERMINUS_URL="https://appliedspin.duckdns.org:8363"
TERMINUS_USER="tim"
TERMINUS_PASS="InitialPass123!"
TERMINUS_DB="admin/project_memory"

terminus_api() {
    curl -k -u $TERMINUS_USER:$TERMINUS_PASS -H "Content-Type: application/json" "$TERMINUS_URL/api/$1"
}

terminus_api_post() {
    curl -k -u $TERMINUS_USER:$TERMINUS_PASS -H "Content-Type: application/json" -X POST -d "$2" "$TERMINUS_URL/api/$1"
}

terminus_api_put() {
    curl -k -u $TERMINUS_USER:$TERMINUS_PASS -H "Content-Type: application/json" -X PUT -d "$2" "$TERMINUS_URL/api/$1"
}

terminus_info() {
    terminus_api "info"
}

terminus_get_schema() {
    terminus_api "schema/$1"
}

terminus_test() {
    echo "Testing TerminusDB connection..."
    terminus_info
}

terminus_update_schema_file() {
    curl -k -u $TERMINUS_USER:$TERMINUS_PASS -H "Content-Type: application/json" -X PUT -d "@$2" "$TERMINUS_URL/api/schema/$1"
}

terminus_update_schema_doc() {
    curl -k -u $TERMINUS_USER:$TERMINUS_PASS -H "Content-Type: application/json" -X POST -d "@$2" "$TERMINUS_URL/api/document/$1"
}

# Knowledge Unit Management
create_knowledge_unit() {
    local name="$1"
    local unit_type="$2"
    local domain="$3"
    local content="$4"
    local tags="$5"
    local created="$6"
    
    local data=$(cat << EOF
{
    "@type": "KnowledgeUnit",
    "name": "$name",
    "unitType": "$unit_type",
    "domain": "$domain",
    "content": $content,
    "tags": $tags,
    "created": "$created",
    "updated": "$created",
    "version": 1
}
EOF
)
    terminus_api_post "document/$TERMINUS_DB?author=$TERMINUS_USER&message=Create%20knowledge%20unit%20$name" "$data"
}

update_knowledge_unit() {
    local id="$1"
    local content="$2"
    local tags="$3"
    local updated="$4"
    local version="$5"
    
    local data=$(cat << EOF
{
    "@id": "$id",
    "@type": "KnowledgeUnit",
    "content": $content,
    "tags": $tags,
    "updated": "$updated",
    "version": $version
}
EOF
)
    terminus_api_put "document/$TERMINUS_DB?author=$TERMINUS_USER&message=Update%20knowledge%20unit%20$id" "$data"
}

get_knowledge_unit() {
    local name="$1"
    terminus_api "document/$TERMINUS_DB?type=KnowledgeUnit&id=KnowledgeUnit/$name"
}

# Enhanced search functionality with improved query patterns and proper type handling
search_knowledge_units() {
    local query="$1"
    local field="${2:-}"  # Optional field specifier
    local count="${3:-50}"  # Optional result count (default 50)
    local start="${4:-0}"  # Optional start position for pagination
    
    # Validate count range (1-100)
    if [ "$count" -lt 1 ] || [ "$count" -gt 100 ]; then
        count=50
    fi
    
    # Validate start position (non-negative)
    if [ "$start" -lt 0 ]; then
        start=0
    fi

    # Base filter for KnowledgeUnit type
    local filter="%7B%22%40type%22%3A%22KnowledgeUnit%22"
    
    # Add field-specific filter
    if [ -n "$field" ]; then
        case "$field" in
            "content")
                # Array text search
                filter="$filter%2C%22content%22%3A%7B%22%24contains%22%3A%22$query%22%7D"
                ;;
            "tags")
                # Set membership
                filter="$filter%2C%22tags%22%3A%22$query%22"
                ;;
            "domain")
                # Enum value match
                query=$(echo "$query" | sed -E 's/^([a-z])/\U\1/g' | sed -E 's/^([^a-z]*)([a-z])/\1\U\2/g')
                filter="$filter%2C%22domain%22%3A%22$query%22"
                ;;
            "unitType")
                # Enum value match
                query=$(echo "$query" | sed -E 's/^([a-z])/\U\1/g' | sed -E 's/^([^a-z]*)([a-z])/\1\U\2/g')
                filter="$filter%2C%22unitType%22%3A%22$query%22"
                ;;
            "name")
                # String exact match
                filter="$filter%2C%22name%22%3A%22$query%22"
                ;;
            *)
                # Default to content search
                filter="$filter%2C%22content%22%3A%7B%22%24contains%22%3A%22$query%22%7D"
                ;;
        esac
    else
        # Full text search in content
        filter="$filter%2C%22content%22%3A%7B%22%24contains%22%3A%22$query%22%7D"
    fi

    # Close the filter object
    filter="$filter%7D"
    
    # Build query parameters
    local params="filter=$filter"
    
    # Add pagination if needed
    if [ "$count" -ne 50 ] || [ "$start" -ne 0 ]; then
        params="$params&count=$count&start=$start"
    fi
    
    # Execute query with error handling
    local response
    response=$(terminus_api "document/$TERMINUS_DB?$params")
    local status=$?
    
    if [ $status -ne 0 ]; then
        echo "Error: API call failed with status $status" >&2
        echo "Query parameters: $params" >&2
        return $status
    fi
    
    # Check for empty results or errors
    if [[ "$response" == "[]" || "$response" =~ "error" ]]; then
        echo "No results found" >&2
        echo "Query parameters: $params" >&2
        return 1
    fi
    
    # Output results
    echo "$response"
}

# Knowledge Relation Management
create_relation() {
    local source="$1"
    local target="$2"
    local relation_type="$3"
    local metadata="$4"
    local created="$5"
    
    local data=$(cat << EOF
{
    "@type": "KnowledgeRelation",
    "sourceUnit": "KnowledgeUnit/$source",
    "targetUnit": "KnowledgeUnit/$target",
    "relationType": "$relation_type",
    "metadata": $metadata,
    "created": "$created"
}
EOF
)
    terminus_api_post "document/$TERMINUS_DB?author=$TERMINUS_USER&message=Create%20relation%20from%20$source%20to%20$target" "$data"
}

get_unit_relations() {
    local unit_id="$1"
    terminus_api "document/$TERMINUS_DB?type=KnowledgeRelation&query=sourceUnit:\"KnowledgeUnit/$unit_id\"%20OR%20targetUnit:\"KnowledgeUnit/$unit_id\""
}

# Validation Functions
validate_unit_type() {
    local type="$1"
    local valid_types=("Process" "Knowledge" "Feature" "Project" "Status" "Infrastructure" "Configuration" "Guidelines" "Documentation" "BestPractice" "Technical" "Requirements" "Research" "Plan" "Architecture" "Verification")
    
    for valid_type in "${valid_types[@]}"; do
        if [ "$type" = "$valid_type" ]; then
            return 0
        fi
    done
    return 1
}

validate_domain() {
    local domain="$1"
    local valid_domains=("Project" "Development" "Infrastructure" "Process" "Security")
    
    for valid_domain in "${valid_domains[@]}"; do
        if [ "$domain" = "$valid_domain" ]; then
            return 0
        fi
    done
    return 1
}

validate_relation_type() {
    local type="$1"
    local valid_types=("implements" "contains" "definesPractices" "implementsPattern" "verifiesProcess" "definesStandards" "definesWorkflow" "managesData" "providesCapabilities" "definesSecurity" "providesTools" "definesProcedures" "definesProcesses" "optimizesProcess" "providesConfiguration" "providesIntegration" "validatesProgress" "supersedes" "requires")
    
    for valid_type in "${valid_types[@]}"; do
        if [ "$type" = "$valid_type" ]; then
            return 0
        fi
    done
    return 1
}

# Database Management
list_knowledge_units() {
    terminus_api "document/$TERMINUS_DB?type=KnowledgeUnit"
}

list_relations() {
    terminus_api "document/$TERMINUS_DB?type=KnowledgeRelation"
}

check_unit_exists() {
    local name="$1"
    local result=$(terminus_api "document/$TERMINUS_DB?type=KnowledgeUnit&id=KnowledgeUnit/$name")
    if [[ $result == *"not_found"* ]]; then
        return 1
    fi
    return 0
}

delete_knowledge_unit() {
    local name="$1"
    terminus_api_delete "document/$TERMINUS_DB?id=KnowledgeUnit/$name&author=$TERMINUS_USER&message=Delete%20knowledge%20unit%20$name"
}

delete_relation() {
    local source="$1"
    local target="$2"
    local type="$3"
    terminus_api_delete "document/$TERMINUS_DB?type=KnowledgeRelation&sourceUnit=KnowledgeUnit/$source&targetUnit=KnowledgeUnit/$target&relationType=$type&author=$TERMINUS_USER&message=Delete%20relation"
}

# Array formatting helper
format_array() {
    # Remove newlines and extra spaces
    local content=$(echo "$*" | tr '\n' ' ' | sed 's/  */ /g')
    # Split into array and format as JSON
    printf '['
    local first=true
    for item in $content; do
        if [ "$first" = true ]; then
            printf '"%s"' "$item"
            first=false
        else
            printf ', "%s"' "$item"
        fi
    done
    printf ']'
}

format_content_array() {
    local content="$*"
    echo "$content" | awk 'BEGIN {printf "["} {printf "%s\"%s\"", (NR==1)?"":",", $0} END {printf "]"}'
}