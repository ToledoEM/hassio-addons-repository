# Nginx Proxy Manager + Static Web Server

A Home Assistant add-on combining [Nginx Proxy Manager](https://nginxproxymanager.com/) with a configurable static file server.

## Features

- Full NPM reverse proxy management via web UI on port 81
- Static file server on port 80 served from a user-configured HA storage path
- Persistent NPM configuration, SSL certificates, and proxy host definitions
- Supports amd64 and aarch64

## Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `static_site_enabled` | `true` | Enable or disable the static file server |
| `static_site_root` | `/share/www` | Path to serve files from |
| `static_site_prefix` | `/` | URL prefix for the static site on port 80 |
| `log_level` | `info` | Logging verbosity |

## Path Notes

- `/share`, `/media`, `/config` — fully supported; HA maps these volumes automatically.
- `/mnt` — allowed with a warning. HA cannot map `/mnt` via the add-on manifest. If files are not accessible, create a symlink under `/share` or `/media` pointing to your `/mnt` target.
- Dangerous system paths (`/`, `/etc`, `/bin`, `/lib`, `/proc`, `/sys`) are blocked and will prevent startup.

## Default NPM credentials

On first login to the NPM UI (port 81):
- Email: `admin@example.com`
- Password: `changeme`

Change these immediately after first login.

## Step-by-Step Setup Guide

1. **Start the Add-on**
   - In Home Assistant, go to **Settings → Add-ons → Nginx Proxy Manager + Static Web Server**
   - Click **Start**
   - (Optional) Enable **Watchdog** to auto-restart if it crashes
   - Check **Logs** to verify startup — you should see:
     ```
     [nginx-proxy-manager-addon] Static site config written → /data/nginx/default_host/static_site.conf
     [nginx-proxy-manager-addon] Handing off to NPM: exec /init
     ```

2. **Access the NPM Admin UI**
   - Open browser and navigate to: `http://<your-ha-ip>:81`
   - Log in with default credentials:
     - Email: `admin@example.com`
     - Password: `changeme`
   - **You will be forced to change the password on first login** — set a strong new password

3. **Change Admin Credentials**
   - After login, go to **Settings → Users**
   - Click the admin user
   - Update password and email
   - Save changes

### Serving a Static Website

4. **Prepare Your Static Files**
   - On your Home Assistant machine, create or upload your website files to: `/share/www/`
   - Supported files: `index.html`, CSS, JavaScript, images, etc.
   - Example structure:
     ```
     /share/www/
     ├── index.html
     ├── css/
     │   └── style.css
     ├── js/
     │   └── script.js
     └── images/
         └── logo.png
     ```

5. **Configure Static Site Settings (if needed)**
   - In Home Assistant, go to **Settings → Add-ons → Nginx Proxy Manager + Static Web Server**
   - Click **Configuration** tab
   - Adjust settings (usually defaults are fine):
     - `static_site_enabled`: `true` (enable the static server)
     - `static_site_root`: `/share/www` (path to your files)
     - `static_site_prefix`: `/` (serves at root URL, use `/docs` or `/blog` for subpaths)
     - `log_level`: `info` (change to `debug` for troubleshooting)
   - Click **Save**
   - Restart the add-on for changes to take effect

6. **Access Your Static Site**
   - Open browser and navigate to: `http://<your-ha-ip>:80` or just `http://<your-ha-ip>`
   - You should see your `index.html` file served

### Setting Up Reverse Proxies (Advanced)

7. **Create Your First Proxy Host**
   - In NPM Admin UI (port 81), go to **Proxy Hosts**
   - Click **Add Proxy Host**
   - Fill in:
     - **Domain Names**: Enter your domain (e.g., `example.com` or `app.example.com`)
     - **Scheme**: Select `http` or `https`
     - **Forward Hostname/IP**: Enter your backend service IP (e.g., `192.168.1.100`)
     - **Forward Port**: Enter backend service port (e.g., `8080`)
     - **Cache Assets**: Optional, improve performance
   - Click **Save**

8. **Enable SSL Certificate (for HTTPS)**
    - In the proxy host you just created, go to the **SSL** tab
    - Click **Request a New SSL Certificate**
    - Check **Use a DNS challenge** (if applicable) or **Use a File Validation challenge**
    - Enter email address for certificate notifications
    - Click **Save**
    - Wait 30 seconds for certificate to be issued
    - Verify **SSL Certificate Status** shows green checkmark

9. **Test Your Proxy**
    - Access your domain in a browser: `https://example.com`
    - Should forward to your backend service
    - Check **Logs** in Home Assistant for any errors

### Hosting Multiple Websites

10. **Add More Proxy Hosts**
    - Repeat steps 7-9 for each additional domain/service you want to proxy
    - Examples:
      - `myapp.example.com` → backend service at `192.168.1.100:8080`
      - `docs.example.com` → backend service at `192.168.1.150:3000`
      - `api.example.com` → backend service at `192.168.1.200:5000`

11. **Add Static Sites on Different Paths**
    - Create subdirectories under `/share/www/`:
      ```
      /share/www/
      ├── index.html (main site at /)
      ├── blog/ (optional, use static_site_prefix: /blog)
      └── docs/ (optional, requires additional NPM configuration)
      ```
    - For serving at different paths, use NPM's **Location** feature on your proxy host

### DNS Configuration (Pi-hole & AdGuard Home)

12. **Add Proxy Domains to Pi-hole**
    - In Pi-hole Admin UI, go to **Local DNS → DNS Records**
    - For each proxy host domain, add a DNS record:
      - **Domain**: `example.com` (the domain you configured in NPM)
      - **IP Address**: `<your-ha-ip>` (same as Home Assistant IP)
      - Click **Add**
    - Repeat for all proxy host domains:
      ```
      myapp.example.com → <your-ha-ip>
      docs.example.com → <your-ha-ip>
      api.example.com → <your-ha-ip>
      ```
    - Save settings — Pi-hole will resolve these domains locally to your HA instance

13. **Add Proxy Domains to AdGuard Home**
    - In AdGuard Home dashboard, go to **Filters → DNS Rewrites**
    - For each proxy host domain, add a rewrite rule:
      - **Domain**: `example.com`
      - **IPv4**: `<your-ha-ip>` (same as Home Assistant IP)
      - Click **Save**
    - Repeat for all proxy host domains:
      ```
      myapp.example.com → <your-ha-ip>
      docs.example.com → <your-ha-ip>
      api.example.com → <your-ha-ip>
      ```
    - Changes apply immediately — no restart needed

14. **Verify DNS Resolution**
    - On any device on your network, test DNS resolution:
      - Linux/Mac: `nslookup example.com` or `dig example.com`
      - Windows: `nslookup example.com`
      - Should return your HA IP address
    - Or test in browser: `http://example.com` should load your proxied service
    - If not working, verify:
      - Device is using Pi-hole/AdGuard Home as DNS server
      - Domain name exactly matches what you configured in NPM

### Troubleshooting

15. **Check Logs**
    - Home Assistant: **Settings → Add-ons → Nginx Proxy Manager + Static Web Server → Logs**
    - NPM UI: **Dashboard → Logs** for per-host debugging
    - Look for error messages about port conflicts, path permissions, or SSL issues

16. **Common Issues**

    **Port Already in Use**
    - Ports 80, 81, or 443 might be in use by another service
    - Check: `netstat -tuln | grep -E ":80|:81|:443"`
    - Disable conflicting services or change port mappings in add-on settings

    **Static Files Not Loading**
    - Verify files exist in `/share/www/`
    - Check file permissions: should be readable by the nginx user
    - Check **Logs** for permission denied errors
    - Try creating a test `index.html` with simple content

    **Proxy Not Reaching Backend**
    - Verify backend service is running and accessible
    - Check firewall rules on backend machine
    - Verify IP/port in proxy host configuration
    - Test backend directly: `curl http://192.168.1.100:8080`

    **SSL Certificate Issues**
    - Ensure your domain is publicly resolvable (or use DNS challenge)
    - Check firewall allows port 80/443 access from internet
    - Review NPM logs for ACME validation errors
    - Reissue certificate: delete old one and create new SSL cert

17. **Restart Add-on**
    - If something breaks, restart from **Settings → Add-ons → Nginx Proxy Manager + Static Web Server → Restart**
    - Configuration persists; no data is lost
