#!/bin/bash
# scripts/restart.sh - Restart Phase 0 environment

echo "🔄 Restarting CyberShield Labs Phase 0..."

# Stop everything first
echo "   🛑 Stopping all containers..."
docker-compose down

# Wait a moment
sleep 5

# Check Docker status
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop first."
    exit 1
fi

# Start everything back up
echo "   🚀 Starting essential services..."
docker-compose up -d guac-db guacd guacamole

echo "   ⏳ Waiting for services to initialize..."
sleep 30

echo "   🎯 Starting student environments..."
docker-compose up -d kali-student1 vulnerable-target1

# Check if user wants student 2
echo ""
read -p "💡 Also start Student 2 environment? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker-compose --profile optional up -d kali-student2 vulnerable-target2
fi

echo ""
echo "📊 Service status:"
docker-compose ps

echo ""
echo "✅ CyberShield Labs Phase 0 restarted!"
echo "🌐 Access at: http://localhost:8080/guacamole"
echo "👤 Login: guacadmin / guacadmin"
