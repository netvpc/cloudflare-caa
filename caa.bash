#!/bin/bash

# 필요한 정보 설정
API_TOKEN=""
ZONE_ID=""
DOMAIN=""

# CAA 레코드 데이터 배열
declare -a caa_records=(
  '0 issue amazonaws.com; cansignhttpexchanges=yes'
  '0 issuewild amazonaws.com; cansignhttpexchanges=yes'
  '0 issue awstrust.com; cansignhttpexchanges=yes'
  '0 issuewild awstrust.com; cansignhttpexchanges=yes'
  '0 issue amazon.com; cansignhttpexchanges=yes'
  '0 issuewild amazon.com; cansignhttpexchanges=yes'
  '0 issue amazontrust.com; cansignhttpexchanges=yes'
  '0 issuewild amazontrust.com; cansignhttpexchanges=yes'
)

# CAA 레코드 업데이트
for record in "${caa_records[@]}"; do
  echo "Adding CAA record: $record"
  
  # 필드를 분리하여 JSON 포맷에 맞게 변환
  IFS=' ' read -r flag tag value <<< "$record"

  data=$(jq -n \
    --arg type "CAA" \
    --arg name "$DOMAIN" \
    --arg tag "$tag" \
    --arg value "$value" \
    --argjson ttl 3600 \
    --argjson flag $flag \
    '{type: $type, name: $name, ttl: $ttl, data: {flags: $flag, tag: $tag, value: $value}}')

  curl -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records" \
    -H "Authorization: Bearer ${API_TOKEN}" \
    -H "Content-Type: application/json" \
    --data "$data" | jq
done
