# Project Goals for AI Assistance: CyberShield Labs

This document outlines specific tasks and areas where AI assistance is desired to accelerate and optimize the CyberShield Labs project.

## General AI Goals:

* **Code Generation:** Generate shell scripts (Bash), Python scripts, and potentially YAML/JSON configurations for automation.
* **Troubleshooting & Debugging:** Help identify root causes for errors based on logs and described symptoms.
* **Best Practices:** Provide recommendations for security, performance, and maintainability.
* **Documentation Enhancement:** Suggest improvements to existing documentation or generate new sections.
* **Concept Explanation:** Clarify technical concepts (e.g., Guacamole API, Cloudflare Tunnel details).

## Specific AI Tasks:

### 🚀 **Priority 1: Phase 1 Cloud Proof-of-Concept**
1.  **Docker Compose Lab Setup:**
    * **Primary Request:** Create a complete Docker Compose configuration that can be deployed on any cloud VPS to provide:
        * Apache Guacamole server with MySQL backend
        * 2-3 Kali Linux containers with pre-installed tools
        * 1-2 Metasploitable2 containers (or DVWA alternatives)
        * Isolated Docker networks for each student "lab"
        * Cloudflare Tunnel integration for external access
    * **Deliverable:** `docker-compose.yml` + configuration files for instant deployment

2.  **Cloud Deployment Automation:**
    * **Primary Request:** Create bash/PowerShell scripts for one-click cloud deployment:
        * DigitalOcean/Linode/AWS instance creation
        * Automated Docker installation and lab deployment
        * Cloudflare tunnel configuration
        * Student account creation and Guacamole connection setup
    * **Deliverable:** `./deploy_cloud_lab.sh` script for complete automation

### 🎯 **Priority 2: Dedicated Server Implementation**

1.  **Automated Lab Deployment Script:**
    * **Primary Request:** Enhanced version of the Python script in `implementation_scripts.md` that:
        * Reads student roster from CSV file
        * Clones Kali LXC and Metasploitable2 VM templates
        * Creates isolated network bridges (`vmbrX`) automatically
        * Configures static IP assignments or DHCP
        * Integrates with Guacamole REST API for connection creation
        * Includes comprehensive error handling and rollback capabilities
        * Generates deployment reports and connection details for students
    * **Enhanced Features:** Resource optimization, parallel deployment, health monitoring

2.  **Template Creation Automation:**
    * **Primary Request:** Improve the template creation scripts in `implementation_scripts.md`:
        * Automated Kali tool selection based on curriculum needs
        * Security hardening automation (firewall, user accounts, SSH keys)
        * Template validation and testing scripts
        * Snapshot management for easy template updates
    * **Deliverable:** Production-ready template creation with curriculum customization

3.  **Advanced Guacamole Integration:**
    * **Primary Request:** Complete Guacamole API management system:
        * User group management (by class, semester, etc.)
        * Connection permission assignment
        * Session monitoring and time limits
        * Automated cleanup of expired labs
        * Integration with school authentication systems (if possible)
    * **Deliverable:** `GuacamoleManager` class with full CRUD operations

### 🎮 **Priority 3: Gaming PC Fleet Management**

4.  **Gaming PC Dual-Boot Automation:**
    * **Primary Request:** Enhance the dual-boot scripts in `implementation_scripts.md`:
        * Automated Windows partition resizing (non-destructive)
        * Unattended Proxmox installation on secondary partition
        * GRUB configuration with Windows default priority
        * Health monitoring and automatic fallback to Windows
        * Remote management capabilities via WoL and IPMI
    * **Critical Requirement:** Zero risk to gaming functionality

5.  **Distributed Cluster Management:**
    * **Primary Request:** Create cluster orchestration system:
        * Dynamic node discovery as gaming PCs come online
        * Load balancing of student labs across available nodes
        * Centralized monitoring dashboard
        * Automated failover when gaming PCs switch to gaming mode
        * Resource optimization based on gaming PC specifications
    * **Deliverable:** `ClusterManager` system for enterprise-scale operation

6.  **Gaming Mode Protection System:**
    * **Primary Request:** Comprehensive protection and monitoring:
        * Performance baseline establishment before dual-boot
        * Automated performance validation after lab sessions
        * Emergency gaming mode activation (<30 seconds)
        * Gaming session monitoring to prevent conflicts
        * Automated alerts for any gaming performance degradation
    * **Deliverable:** Zero-impact guarantee system with monitoring dashboard

### 📊 **Cross-Cutting Automation Goals**

7.  **Resource Optimization Engine:**
    * **Primary Request:** Intelligent resource management:
        * Dynamic resource allocation based on available hardware
        * Student usage pattern analysis and prediction
        * Automated scaling recommendations
        * Cost optimization for cloud hybrid scenarios
        * Performance tuning based on actual usage data

8.  **Monitoring and Alerting System:**
    * **Primary Request:** Comprehensive monitoring solution:
        * Real-time infrastructure health monitoring
        * Student activity and progress tracking
        * Security incident detection and response
        * Automated reporting for administration
        * Predictive maintenance alerts

9.  **Curriculum Integration Tools:**
    * **Primary Request:** Educational workflow automation:
        * Lab exercise deployment and grading integration
        * Student progress tracking and analytics
        * Automated lab reset between classes
        * Assignment-specific environment provisioning
        * Integration with learning management systems

### 🔧 **Implementation Support Requests**

10. **Code Review and Optimization:**
    * Review generated scripts for security best practices
    * Performance optimization recommendations
    * Error handling and logging improvements
    * Code documentation and maintenance guides

11. **Troubleshooting Automation:**
    * Automated diagnostics for common failure scenarios
    * Self-healing scripts for routine issues
    * Comprehensive logging and debugging tools
    * Recovery procedures for various failure modes

12. **Documentation Generation:**
    * Automated documentation from code comments
    * User guides for teachers and students
    * Technical documentation for IT staff
    * Runbook creation for daily operations

### 📋 **Implementation Phases and AI Support Priority**

**Phase 1 (Cloud PoC) - Immediate AI Support Needed:**
- Docker Compose lab setup (Priority 1.1)
- Cloud deployment automation (Priority 1.2)
- Basic Guacamole integration

**Phase 2 (Dedicated Server) - Medium-term AI Support:**
- Enhanced lab deployment automation (Priority 2.1)
- Template creation optimization (Priority 2.2)
- Advanced Guacamole management (Priority 2.3)

**Phase 3 (Gaming PC Fleet) - Advanced AI Support:**
- Gaming PC dual-boot system (Priority 3.4)
- Distributed cluster management (Priority 3.5)
- Gaming mode protection (Priority 3.6)

**Ongoing Support:**
- Resource optimization (Priority 7)
- Monitoring systems (Priority 8)
- Curriculum integration (Priority 9)

### 💡 **AI Collaboration Approach**

**Iterative Development:**
- Start with working minimum viable solutions
- Gradually add features and sophistication
- Test each component thoroughly before integration
- Maintain backward compatibility during upgrades

**Risk-Minimized Coding:**
- Always include rollback capabilities
- Extensive logging and error handling
- Dry-run modes for testing
- Comprehensive validation before execution

**Educational Focus:**
- Code should be readable and educational
- Include comments explaining cybersecurity concepts
- Provide learning opportunities through implementation
- Document security best practices throughout

## "Vibe-Coding" Integration:

* **Interactive Sessions:** I will feed pieces of this context and ask for specific code blocks or conceptual explanations.
* **Iterative Refinement:** I'll provide feedback on generated code/text, and the AI should adapt and refine its output based on my preferences and constraints.
* **Problem-Solving Partner:** Treat the AI as a technical co-pilot, helping to brainstorm solutions, identify potential pitfalls, and generate implementation details.

This structured approach should give the AI a clear understanding of the project's scope, current state, and where its assistance is most valuable.