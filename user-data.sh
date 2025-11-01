#!/bin/bash

# EC2 User Data Script for HousingNator
# This script runs automatically when the EC2 instance starts

yum update -y

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Node.js
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Install Git
yum install -y git

# Create application directory
mkdir -p /home/ec2-user/housingnator
chown ec2-user:ec2-user /home/ec2-user/housingnator

# Create simple web application
cat > /home/ec2-user/housingnator/index.html << 'EOF'
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

# Create simple Node.js API server
cat > /home/ec2-user/housingnator/server.js << 'EOF'
const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 4000;

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        version: '1.0.0',
        server: 'HousingNator API'
    });
});

// Properties endpoint
app.get('/api/properties', (req, res) => {
    res.json({
        properties: [
            {
                id: 1,
                title: 'Modern Downtown Apartment',
                type: 'apartment',
                category: 'traditional',
                price: 2500,
                location: 'Downtown Seattle',
                bedrooms: 2,
                bathrooms: 2,
                amenities: ['parking', 'gym', 'pool']
            },
            {
                id: 2,
                title: 'Co-living Space in Tech Hub',
                type: 'co-living',
                category: 'non-traditional',
                price: 1200,
                location: 'South Lake Union',
                bedrooms: 1,
                bathrooms: 1,
                amenities: ['workspace', 'community-events', 'cleaning-service']
            }
        ],
        total: 2,
        timestamp: new Date().toISOString()
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 HousingNator API running on port ${PORT}`);
});
EOF

# Create package.json for the API
cat > /home/ec2-user/housingnator/package.json << 'EOF'
{
    "name": "housingnator-simple",
    "version": "1.0.0",
    "description": "Simple HousingNator API",
    "main": "server.js",
    "scripts": {
        "start": "node server.js"
    },
    "dependencies": {
        "express": "^4.19.2"
    }
}
EOF

# Install nginx
yum install -y nginx

# Configure nginx
cat > /etc/nginx/conf.d/housingnator.conf << 'EOF'
server {
    listen 80 default_server;
    server_name _;
    root /home/ec2-user/housingnator;
    index index.html;

    # Serve static files
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Proxy API requests
    location /api/ {
        proxy_pass http://127.0.0.1:4000/api/;
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

# Remove default nginx config
rm -f /etc/nginx/conf.d/default.conf

# Start nginx
systemctl start nginx
systemctl enable nginx

# Install and start the API server
cd /home/ec2-user/housingnator
npm install
chown -R ec2-user:ec2-user /home/ec2-user/housingnator

# Create systemd service for the API
cat > /etc/systemd/system/housingnator-api.service << 'EOF'
[Unit]
Description=HousingNator API Server
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/housingnator
ExecStart=/usr/bin/node server.js
Restart=on-failure
Environment=NODE_ENV=production
Environment=PORT=4000

[Install]
WantedBy=multi-user.target
EOF

# Start the API service
systemctl daemon-reload
systemctl start housingnator-api
systemctl enable housingnator-api

# Log deployment completion
echo "$(date): HousingNator deployment completed successfully" >> /var/log/housingnator-deploy.log