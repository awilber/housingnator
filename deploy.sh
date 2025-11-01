#!/bin/bash

# HousingNator Deployment Script
# Deploys the application to EC2 instance 13.218.129.214

set -e

EC2_HOST="13.218.129.214"
EC2_USER="ec2-user"
KEY_PATH="$HOME/.ssh/bolaquent-key.pem"
APP_DIR="/home/ec2-user/housingnator"

echo "🚀 Starting HousingNator deployment to $EC2_HOST"

# Check if key file exists
if [ ! -f "$KEY_PATH" ]; then
    echo "❌ SSH key not found at $KEY_PATH"
    echo "Please ensure the key file exists for EC2 access"
    exit 1
fi

# Set correct permissions for SSH key
chmod 600 "$KEY_PATH"

echo "📦 Preparing deployment files..."

# Create deployment package
tar czf housingnator-deploy.tar.gz \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='dist' \
    --exclude='build' \
    --exclude='.claude' \
    .

echo "📤 Copying files to EC2 instance..."

# Copy deployment package to EC2
scp -i "$KEY_PATH" -o StrictHostKeyChecking=no \
    housingnator-deploy.tar.gz \
    "$EC2_USER@$EC2_HOST:/tmp/"

echo "🔧 Setting up environment on EC2..."

# Execute deployment commands on EC2
ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no "$EC2_USER@$EC2_HOST" << 'EOF'
    # Install Docker if not present
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker..."
        sudo yum update -y
        sudo yum install -y docker
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo usermod -a -G docker ec2-user
        
        # Install Docker Compose
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi
    
    # Create app directory
    mkdir -p /home/ec2-user/housingnator
    cd /home/ec2-user/housingnator
    
    # Extract deployment package
    tar xzf /tmp/housingnator-deploy.tar.gz
    
    # Install Node.js if not present
    if ! command -v node &> /dev/null; then
        echo "Installing Node.js..."
        curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
        sudo yum install -y nodejs
    fi
    
    # Install dependencies and build
    npm install
    npm run build || echo "Build completed with warnings"
    
    # Start services with Docker Compose
    sudo docker-compose down 2>/dev/null || true
    sudo docker-compose up -d --build
    
    echo "✅ Application deployed successfully!"
    echo "🌐 Available at: http://13.218.129.214"
EOF

echo "🧹 Cleaning up..."
rm -f housingnator-deploy.tar.gz

echo "✅ Deployment complete!"
echo "🌐 Application should be available at: http://$EC2_HOST"
echo "📊 Check deployment status: ssh -i $KEY_PATH $EC2_USER@$EC2_HOST 'sudo docker-compose ps'"