#!/bin/bash
# scripts/cleanup.sh - Clean up Phase 0 environment

echo "🧹 Cleaning up CyberShield Labs Phase 0..."

# Stop all containers
echo "   🛑 Stopping all containers..."
docker-compose down

echo ""
echo "📊 Current Docker resource usage:"
docker system df

echo ""
# Ask about removing student data
read -p "🗑️  Remove all student data and lab progress? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "   🗑️  Removing student data volumes..."
    docker-compose down -v
    echo "   ✅ Student data removed"
else
    echo "   💾 Student data preserved for next session"
fi

echo ""
# Ask about removing Docker images to free space
read -p "🗑️  Remove Docker images to free disk space? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "   🗑️  Removing unused Docker images..."
    docker system prune -f
    echo "   🗑️  Removing CyberShield images..."
    docker rmi $(docker images | grep cybershield | awk '{print $3}') 2>/dev/null || true
    echo "   ✅ Docker images cleaned up"
else
    echo "   💾 Docker images preserved for faster restart"
fi

echo ""
echo "📊 Final Docker resource usage:"
docker system df

echo ""
echo "✅ Cleanup completed!"
echo ""
echo "🔄 To restart CyberShield Labs:"
echo "   ./scripts/setup.sh"
echo ""
echo "💡 Performance tip: Keep images if you plan to use this again soon"
