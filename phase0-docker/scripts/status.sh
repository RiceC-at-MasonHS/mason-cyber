#!/bin/bash
# scripts/status.sh - Check status of all services

echo "📊 CyberShield Labs Phase 0 Status"
echo "=================================="

# Check Docker
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running"
    exit 1
else
    echo "✅ Docker is running"
fi

echo ""
echo "🐳 Container Status:"
docker-compose ps --format "table {{.Service}}\t{{.State}}\t{{.Ports}}"

echo ""
echo "💾 Resource Usage:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"

echo ""
echo "📡 Network Connectivity:"
echo "   Testing web interface..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/guacamole | grep -q "200\|302"; then
    echo "   ✅ Guacamole web interface accessible"
else
    echo "   ❌ Guacamole web interface not responding"
fi

echo ""
echo "🔍 Quick Health Check:"
healthy_containers=$(docker-compose ps --filter "status=running" --format json | jq -r '.State' | grep -c "running")
total_containers=$(docker-compose ps --format json | jq -r '.State' | wc -l)

if [ "$healthy_containers" -eq "$total_containers" ] && [ "$total_containers" -gt 0 ]; then
    echo "   ✅ All containers healthy ($healthy_containers/$total_containers)"
else
    echo "   ⚠️  Some containers may have issues ($healthy_containers/$total_containers running)"
fi

echo ""
echo "🌐 Access URLs:"
echo "   Main Interface: http://localhost:8080/guacamole"
echo "   Login: guacadmin / guacadmin"
