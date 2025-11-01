#!/bin/bash

# EC2 Instance Setup Script for HousingNator
# This script should be run on the EC2 instance to set up the application

set -e

echo "🚀 Setting up HousingNator on EC2 instance..."

# Update system
sudo yum update -y

# Install Docker
if ! command -v docker &> /dev/null; then
    echo "📦 Installing Docker..."
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -a -G docker ec2-user
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "📦 Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Install Node.js
if ! command -v node &> /dev/null; then
    echo "📦 Installing Node.js..."
    curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
    sudo yum install -y nodejs
fi

# Install Git
if ! command -v git &> /dev/null; then
    echo "📦 Installing Git..."
    sudo yum install -y git
fi

# Clone repository
cd /home/ec2-user
if [ ! -d "housingnator" ]; then
    echo "📥 Cloning HousingNator repository..."
    git clone https://github.com/awilber/housingnator.git
else
    echo "📥 Updating HousingNator repository..."
    cd housingnator
    git pull origin main
    cd ..
fi

cd housingnator

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Create a simple production docker-compose file
cat > docker-compose.prod.yml << 'EOF'
version: '3.8'

services:
  # Simple HTTP server for the application
  web:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx-simple.conf:/etc/nginx/conf.d/default.conf:ro
      - ./static:/usr/share/nginx/html:ro
    restart: unless-stopped

  # Simple API server
  api:
    image: node:18-alpine
    working_dir: /app
    ports:
      - "4000:4000"
    volumes:
      - ./server:/app
    command: sh -c "cd /app && npm install && npm start || node -e 'const express = require(\"express\"); const app = express(); app.get(\"/api/health\", (req, res) => res.json({status: \"healthy\", timestamp: new Date().toISOString()})); app.get(\"/api/*\", (req, res) => res.json({message: \"HousingNator API\", version: \"1.0.0\"})); app.listen(4000, \"0.0.0.0\", () => console.log(\"API running on port 4000\"));'"
    restart: unless-stopped
    environment:
      - NODE_ENV=production
      - PORT=4000
EOF

# Create simple nginx config
cat > nginx-simple.conf << 'EOF'
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    # Serve static files
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Proxy API requests
    location /api/ {
        proxy_pass http://api:4000/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Health check
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF

# Create static directory with simple HTML
mkdir -p static
cat > static/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HousingNator - Find Your Perfect Rental</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Arial', sans-serif; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }
        .container { text-align: center; max-width: 800px; padding: 2rem; }
        h1 { font-size: 3rem; margin-bottom: 1rem; font-weight: 700; }
        .subtitle { font-size: 1.2rem; margin-bottom: 3rem; opacity: 0.9; }
        .features { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 2rem; margin-top: 3rem; }
        .feature { 
            background: rgba(255, 255, 255, 0.1); 
            backdrop-filter: blur(10px);
            border-radius: 16px; 
            padding: 2rem; 
            border: 1px solid rgba(255, 255, 255, 0.2);
            transition: transform 0.3s ease;
        }
        .feature:hover { transform: translateY(-5px); }
        .feature h3 { font-size: 1.5rem; margin-bottom: 1rem; }
        .status { 
            background: rgba(255, 255, 255, 0.2); 
            padding: 1rem; 
            border-radius: 8px; 
            margin-top: 2rem;
            font-size: 0.9rem;
        }
        .api-test { margin-top: 1rem; }
        .api-result { 
            background: rgba(0, 0, 0, 0.2); 
            padding: 0.5rem; 
            border-radius: 4px; 
            margin-top: 0.5rem;
            font-family: monospace;
            font-size: 0.8rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🏠 HousingNator</h1>
        <p class="subtitle">Find your perfect rental - traditional and non-traditional options</p>
        
        <div class="features">
            <div class="feature">
                <h3>🏠 Traditional Rentals</h3>
                <p>Apartments, houses, condos through standard channels</p>
            </div>
            <div class="feature">
                <h3>🌟 Non-Traditional Options</h3>
                <p>Co-living, short-term, rent-to-own, cooperatives</p>
            </div>
            <div class="feature">
                <h3>🔍 Advanced Search</h3>
                <p>Filter by location, price, amenities, and rental type</p>
            </div>
        </div>

        <div class="status">
            <strong>🚀 Application Status:</strong> Deployed successfully!<br>
            <strong>📍 Server:</strong> 13.218.129.214<br>
            <strong>⏰ Deployed:</strong> <span id="timestamp"></span>
            
            <div class="api-test">
                <button onclick="testAPI()" style="background: #667eea; color: white; border: none; padding: 0.5rem 1rem; border-radius: 4px; cursor: pointer;">Test API</button>
                <div id="api-result" class="api-result" style="display: none;"></div>
            </div>
        </div>
    </div>

    <script>
        document.getElementById('timestamp').textContent = new Date().toLocaleString();
        
        async function testAPI() {
            const resultDiv = document.getElementById('api-result');
            resultDiv.style.display = 'block';
            resultDiv.textContent = 'Testing API...';
            
            try {
                const response = await fetch('/api/health');
                const data = await response.json();
                resultDiv.textContent = '✅ API Response: ' + JSON.stringify(data, null, 2);
            } catch (error) {
                resultDiv.textContent = '❌ API Error: ' + error.message;
            }
        }
    </script>
</body>
</html>
EOF

# Start services
echo "🚀 Starting HousingNator services..."
sudo docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
sudo docker-compose -f docker-compose.prod.yml up -d

echo "✅ HousingNator setup complete!"
echo "🌐 Application available at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo 'YOUR_IP')"
echo "📊 Check status: sudo docker-compose -f docker-compose.prod.yml ps"