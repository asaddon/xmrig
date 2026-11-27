# XMRig MoneroOcean Docker Image (`asaddon/xmrig-mo`)

[![Docker Pulls](https://img.shields.io/docker/pulls/asaddon/xmrig-mo.svg)](https://hub.docker.com/r/asaddon/xmrig-mo)
[![Docker Image Size](https://img.shields.io/docker/image-size/asaddon/xmrig-mo/latest)](https://hub.docker.com/r/asaddon/xmrig-mo)
[![Multi-Arch](https://img.shields.io/badge/architecture-amd64%20%7C%20arm64-blue.svg)](https://hub.docker.com/r/asaddon/xmrig-mo)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

A high-performance, lightweight multi-architecture Docker image for **XMRig (MoneroOcean Edition)** with built-in multi-algorithm switching, TLS encryption, 100% Huge Pages support, and real-time HTTP monitoring.

* **Docker Hub Repositories:**
  * **[`asaddon/xmrig-mo`](https://hub.docker.com/r/asaddon/xmrig-mo)** *(Primary)*
  * **[`asaddon/xmrig-moneroocean`](https://hub.docker.com/r/asaddon/xmrig-moneroocean)** *(Mirror)*
* **Supported Architectures:** `linux/amd64`, `linux/arm64`

---

## What is This Image For?

Standard XMRig only mines RandomX (Monero). This image runs the **MoneroOcean fork** of XMRig, which gives you:

1. **Automatic Algo-Switching:** Tests your CPU speed across dozens of algorithms (RandomX, GhostRider, Panthera, AstroBWT, CryptoNight, etc.) and automatically switches to mine whichever coin is most profitable at any given moment.
2. **Payouts in Pure Monero (XMR):** Regardless of which algorithm your CPU mines, the pool converts all rewards and pays you directly in Monero (XMR).
3. **Out-of-the-Box Optimizations:**
   * Pre-compiled with OpenSSL (SSL/TLS), `hwloc` CPU topology detection, and AVX2/AVX-512 assembly optimizations.
   * Built-in HTTP API on port `18080` for monitoring hashrate and temperatures.
   * Container-friendly resource yielding (`--cpu-priority 0` and `cpu_shares: 64`).

---

## Quick Start (Docker CLI)

Run this one-liner on your Linux server or desktop (replace with your XMR wallet):

```bash
docker run -d \
  --name xmrig-moneroocean \
  --restart unless-stopped \
  --cap-add SYS_NICE \
  -p 18080:18080 \
  -e POOL_URL="gulf.moneroocean.stream:20004" \
  -e WALLET_ADDRESS="YOUR_XMR_WALLET_ADDRESS" \
  -e RIG_ID="My-Miner" \
  asaddon/xmrig-mo:latest
```

---

## Docker Compose / Portainer Stack (Recommended)

Paste this directly into **Portainer** (*Stacks $\rightarrow$ Add stack $\rightarrow$ Web editor*) or save it as `docker-compose.yml`:

```yaml
services:
  xmrig-mo:
    image: asaddon/xmrig-mo:latest
    container_name: xmrig-moneroocean
    restart: unless-stopped

    # Allows container to use low-priority SCHED_IDLE
    cap_add:
      - SYS_NICE

    # Optional: Enable privileged mode only on Bare Metal to unlock Ryzen MSR tweaks
    # privileged: true

    environment:
      # Stratum Pool URL (Port 20004 for TLS)
      - POOL_URL=gulf.moneroocean.stream:20004

      # Your Monero (XMR) Wallet Address
      - WALLET_ADDRESS=YOUR_WALLET_ADDRESS

      # Worker Name on the MoneroOcean dashboard
      - RIG_ID=My-Server

      # Pool Password (default "x")
      - POOL_PASS=x

      # Additional CLI options (e.g. limit thread count, priority, http bind)
      - EXTRA_ARGS=--cpu-priority 0 --http-host 0.0.0.0 --http-port 18080

    # Low CPU weight ensures miner yields to host apps and other containers
    cpu_shares: 64

    # Web monitoring port
    ports:
      - "18080:18080"
```

---

## Environment Variables Reference

| Variable | Default | Description |
| :--- | :--- | :--- |
| `POOL_URL` | `gulf.moneroocean.stream:20004` | Mining pool host and port (`20004` for TLS). |
| `WALLET_ADDRESS` | *(Configured default)* | Your Monero (`4...` or `8...`) wallet address. |
| `RIG_ID` | `Office-Server` | Worker name displayed on pool dashboard. |
| `POOL_PASS` | `x` | Pool password (or custom diff like `x~50000`). |
| `EXTRA_ARGS` | *(None)* | Extra flags passed directly to `xmrig` (e.g. `--threads 8`, `--cpu-priority 0`). |
| `HTTP_PORT` | `18080` | Internal port for the HTTP JSON/Web API. |

---

## Performance Optimizations

### 1. Enable Huge Pages (Huge Hashrate Boost)
RandomX performance increases by **+25% to +35%** when Huge Pages are allocated on the host system:

On your Linux host terminal, run:
```bash
sudo sysctl -w vm.nr_hugepages=1280
echo "vm.nr_hugepages=1280" | sudo tee -a /etc/sysctl.conf
```

### 2. AMD Ryzen MSR Prefetcher Mod (Bare Metal Only)
On dedicated AMD Ryzen servers (e.g. 3900X, 5900X, 7950X), XMRig can apply hardware prefetcher adjustments for an extra **+5% to +8%** hashrate:

```bash
# Load MSR module on the host
sudo modprobe msr
echo "msr" | sudo tee -a /etc/modules
```
Then add `privileged: true` to your Docker Compose file.

### 3. Finding Your Optimal Thread Count
For RandomX, each mining thread requires **2.0 MB of L3 Cache**:
$$\text{Optimal Threads} = \frac{\text{Total L3 Cache (MB)}}{2\text{ MB}}$$

Test different thread allocations using the built-in benchmark:
```bash
# Test 8 threads
docker run --rm asaddon/xmrig-mo --bench=250K --threads=8

# Test 12 threads
docker run --rm asaddon/xmrig-mo --bench=250K --threads=12
```

---

## Live Monitoring

* **Local JSON API:** Open `http://<server-ip>:18080/1/summary` in your browser.
* **XMRig Web Dashboard:** Connect your miner's IP and port `18080` at [workers.xmrig.info](http://workers.xmrig.info).
* **Pool Dashboard:** Track your accepted shares and Monero payouts by searching your wallet address at [moneroocean.stream](https://moneroocean.stream).
