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

## Setup

1. **Start the Add-on**
   - In Home Assistant, go to **Settings → Add-ons → Nginx Proxy Manager + Static Web Server** and click **Start**
   - (Optional) Enable **Watchdog** to auto-restart on crash
   - Verify startup in **Logs**:
     ```
     [nginx-proxy-manager-addon] Static site config written → /data/nginx/default_host/static_site.conf
     [nginx-proxy-manager-addon] Handing off to NPM: exec /init
     ```

2. **Access the NPM Admin UI**
   - Open `http://<your-ha-ip>:81` in your browser
   - Log in with `admin@example.com` / `changeme`
   - Change your password on first login — NPM requires this

3. **Update Admin Credentials**
   - Go to **Settings → Users** and click the admin user
   - Set a strong password and update the email address

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

5. **Configure Static Site Settings**
   - Go to **Settings → Add-ons → Nginx Proxy Manager + Static Web Server → Configuration**
   - Adjust as needed:
     - `static_site_enabled`: `true` to enable static server
     - `static_site_root`: `/share/www` (or your custom path)
     - `static_site_prefix`: `/` for root, or `/docs`, `/blog` etc. for subpaths
     - `log_level`: `debug` to troubleshoot, `info` otherwise
   - Click **Save** and restart the add-on for changes to take effect

6. **Access Your Static Site**
   - Open `http://<your-ha-ip>` in your browser
   - Verify `index.html` loads from `/share/www/`

## Reverse Proxies

7. **Create a Proxy Host**
   - Go to **Proxy Hosts** in the NPM UI and click **Add Proxy Host**
   - Configure:
     - **Domain Names**: `example.com` or `app.example.com`
     - **Scheme**: `http` or `https`
     - **Forward Hostname/IP**: Backend service IP (e.g., `192.168.1.100`)
     - **Forward Port**: Backend service port (e.g., `8080`)
     - **Cache Assets**: Optional—caches static assets at the proxy to reduce backend load
   - Click **Save**

8. **Enable HTTPS**
    - Go to the **SSL** tab on your proxy host
    - Click **Request a New SSL Certificate**
    - Choose **DNS challenge** or **File Validation challenge** depending on your domain setup
    - Enter your email for certificate notifications
    - Click **Save**
    - Certificate issues within 30 seconds; verify the status shows a green checkmark

9. **Test the Proxy**
    - Access `https://example.com` in your browser
    - Verify it forwards to your backend service
    - Check add-on **Logs** for any errors

## Multiple Sites

10. **Add More Proxy Hosts**
    - Repeat steps 7-8 for each domain. Examples:
      - `myapp.example.com` → `192.168.1.100:8080`
      - `docs.example.com` → `192.168.1.150:3000`
      - `api.example.com` → `192.168.1.200:5000`

11. **Serve Static Sites on Subpaths**
    - Create subdirectories under `/share/www/`:
      ```
      /share/www/
      ├── index.html (serves at /)
      ├── blog/ (serves at /blog with static_site_prefix: /blog)
      └── docs/ (use NPM's Location feature for complex routing)
      ```

## DNS Configuration

12. **Pi-hole Setup**
    - Go to **Local DNS → DNS Records** in Pi-hole
    - Add a DNS record for each domain:
      ```
      example.com → <your-ha-ip>
      myapp.example.com → <your-ha-ip>
      docs.example.com → <your-ha-ip>
      api.example.com → <your-ha-ip>
      ```
    - Save — Pi-hole resolves these locally to your HA instance

13. **AdGuard Home Setup**
    - Go to **Filters → DNS Rewrites** in AdGuard Home
    - Add a rewrite rule for each domain (same list as above)
    - Changes apply immediately without restart

14. **Verify DNS Resolution**
    - Test from any device on your network:
      ```bash
      nslookup example.com        # Linux/Mac/Windows
      dig example.com             # Linux/Mac
      ```
    - Should return `<your-ha-ip>`
    - Verify in browser: `http://example.com` loads your proxied service
    - If it fails, check: device uses Pi-hole/AdGuard as DNS, domain name matches NPM config exactly

## Troubleshooting

**Check Logs**
- Home Assistant: **Settings → Add-ons → Nginx Proxy Manager + Static Web Server → Logs**
- NPM UI: **Dashboard → Logs** for per-host issues
- Look for port conflicts, permission errors, or SSL validation failures

**Port Already in Use** (80, 81, or 443)
```bash
netstat -tuln | grep -E ":80|:81|:443"
```
- Disable conflicting services or reassign ports in add-on settings

**Static Files Not Loading**
- Files must exist in `/share/www/` (or your configured `static_site_root`)
- Verify nginx user can read the files: `ls -la /share/www/`
- Check add-on logs for "permission denied"
- Create a test `index.html` with simple content to isolate the issue

**Proxy Not Reaching Backend**
- Verify backend service runs: `curl http://192.168.1.100:8080` from HA host
- Check backend firewall allows traffic from HA IP
- Verify IP/port match the proxy host configuration in NPM

**SSL Certificate Fails**
- Domain must be publicly resolvable (or use DNS challenge for private domains)
- Check firewall allows inbound 80/443 for ACME validation
- Review NPM logs for ACME errors
- Reissue: delete old cert and request new one

**Restart Add-on**
- Go to **Settings → Add-ons → Nginx Proxy Manager + Static Web Server → Restart**
- Configuration and data persist across restarts
