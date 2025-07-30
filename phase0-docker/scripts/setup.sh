#!/bin/bash
# scripts/setup.sh - Phase 0 setup for Dell Latitude 5340

echo "🚀 Setting up CyberShield Labs Phase 0 for your Dell Latitude 5340..."
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop first."
    echo "   1. Open Docker Desktop"
    echo "   2. Wait for it to fully start"
    echo "   3. Run this script again"
    exit 1
fi

echo "✅ Docker is running"

# Check available system resources
echo "📊 Checking system resources..."
TOTAL_MEM=$(docker info --format '{{.MemTotal}}' 2>/dev/null)
if [ ! -z "$TOTAL_MEM" ]; then
    TOTAL_GB=$((TOTAL_MEM / 1024 / 1024 / 1024))
    echo "   Total system memory: ${TOTAL_GB}GB"
fi

echo "   Your Dell Latitude 5340: 16GB RAM, i5-1345U CPU ✅"
echo "   Expected container usage: ~4-5GB total"
echo ""

# Ensure we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Please run this script from the phase0-docker directory"
    echo "   cd phase0-docker"
    echo "   ./scripts/setup.sh"
    exit 1
fi

echo "🏗️  Building lightweight Docker containers..."
echo "   This may take 10-15 minutes on first run..."
echo ""

# Build containers one at a time to avoid memory pressure
echo "📦 Building Kali Lite container..."
if ! docker-compose build kali-student1; then
    echo "❌ Failed to build Kali container"
    exit 1
fi

echo "📦 Building vulnerable target container..."
if ! docker-compose build vulnerable-target1; then
    echo "❌ Failed to build vulnerable target container"
    exit 1
fi

echo ""
echo "🚀 Starting CyberShield Labs Lite (minimal environment)..."

# Start only essential services first
echo "   🗄️  Starting database and Guacamole..."
if ! docker-compose up -d guac-db guacd guacamole; then
    echo "❌ Failed to start Guacamole services"
    exit 1
fi

# Wait for database to be ready
echo "   ⏳ Waiting for database to initialize (45 seconds)..."
sleep 45

echo "   🎯 Starting Student 1 environment..."
if ! docker-compose up -d kali-student1 vulnerable-target1; then
    echo "❌ Failed to start student environment"
    exit 1
fi

# Check if containers are running
echo ""
echo "📊 Checking system performance..."
sleep 30

# Monitor memory usage
echo "   📈 Current Docker resource usage:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" | head -6

echo ""
read -p "💡 System seems stable. Try starting Student 2 environment? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "   🎯 Starting Student 2 environment..."
    if docker-compose --profile optional up -d kali-student2 vulnerable-target2; then
        echo "   ✅ Student 2 environment started successfully"
        STUDENT2_RUNNING=true
    else
        echo "   ⚠️  Student 2 environment failed to start (this is okay)"
        STUDENT2_RUNNING=false
    fi
else
    echo "   👍 Keeping single student environment for optimal performance"
    STUDENT2_RUNNING=false
fi

# Final status check
echo ""
echo "📊 Final service status:"
docker-compose ps

echo ""
echo "🎉 CyberShield Labs Phase 0 is ready!"
echo ""
echo "🌐 Access Guacamole at: http://localhost:8080/guacamole"
echo "👤 Default login: guacadmin / guacadmin"
echo ""
echo "🎯 Student Lab Environments:"
echo "   Student 1: Kali (10.1.0.10) → Target (10.1.0.20)"
if [ "$STUDENT2_RUNNING" = true ]; then
    echo "   Student 2: Kali (10.2.0.10) → Target (10.2.0.20)"
fi
echo ""
echo "⚠️  Performance Tips for your Dell Latitude 5340:"
echo "   💻 Close other applications while running labs"
echo "   📈 Monitor resource usage: docker stats"
echo "   🧹 Clean up when done: ./scripts/cleanup.sh"
echo "   🔄 Restart if performance degrades: ./scripts/restart.sh"
echo ""
echo "🔧 Next Steps:"
echo "   1. Open browser to http://localhost:8080/guacamole"
echo "   2. Login with guacadmin / guacadmin"
echo "   3. Run: ./scripts/setup-connections.sh (to create student connections)"
echo "   4. Start testing your cybersecurity lab!"
echo ""
echo "📚 Quick Test Commands (after connecting to Kali via Guacamole):"
echo "   ping 10.1.0.20         # Test connectivity"
echo "   quickscan 10.1.0.20    # Fast port scan"
echo "   scan 10.1.0.20         # Detailed nmap scan"
echo "   vulnscan 10.1.0.20     # Web vulnerability scan"
echo "   ./cyber-toolkit.sh     # Show all available tools"
