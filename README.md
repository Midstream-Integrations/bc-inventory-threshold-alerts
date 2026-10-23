# Inventory Threshold Alerts for Business Central

![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg) ![Business Central 25+](https://img.shields.io/badge/Business%20Central-25%2B-0B7E8A) ![AL](https://img.shields.io/badge/language-AL-5C2D91)

**Get one email when an item drops below a minimum at a location, not one every 15 minutes.**

<!-- DEMO: record a 30-60 second screen capture, save it as docs/images/demo.gif, then replace this comment with:
![Demo](docs/images/demo.gif) -->

## Why

Reorder points and planning worksheets serve purchasing. The people on the floor (a production lead, a branch manager, customer service) often need to know sooner, and per location. Usually they find out when a pick fails.

## What it does

- **Thresholds per item, location and variant.** Set as many as you need. A blank location watches total inventory; a blank variant covers all variants.
- **One alert per dip.** The line is marked when an alert goes out, and re-arms itself when stock recovers.
- **Recipients that fall back sensibly:** the threshold line's own email, then the location's **Inventory Alert Email**, then the company default on **Inventory Setup**.
- **Check Now** button, and a one-click recurring Job Queue Entry (every 15 minutes by default).
- Last checked quantity, check time and alert time on every line.

## Setup

1. Optionally set a **Default Inventory Alert Email** on **Inventory Setup**, and an **Inventory Alert Email** on each **Location Card**.
2. Open **Inventory Thresholds** (or **Item Card** → **Inventory Thresholds**) and add lines: item, location, minimum quantity, and optionally an email.
3. Choose **Create Job Queue Entry**, review the schedule, and set it to **Ready**.

## Install

**From a release (no build tools needed)**
1. Download the `.app` file from the latest [release](../../releases).
2. In Business Central, open **Extension Management** → **Manage** → **Upload Extension** and select the file.
3. Assign the permission set listed below to the people who use it.

**From source**
1. Clone this repo and open `InventoryThresholdAlerts` in VS Code with the [AL Language extension](https://marketplace.visualstudio.com/items?itemName=ms-dynamics-smb.al).
2. Put your sandbox name and tenant ID in `.vscode/launch.json`, then run **AL: Download Symbols**.
3. Press **F5** to publish to your sandbox.

Always test in a sandbox before you install in production.

## Technical details

| | |
|---|---|
| Object ID range | 50150–50169 |
| Object prefix | `MID` |
| Dependencies | Base Application, System Application |
| Permission set(s) | `MID INV ALERTS` |
| Business Central | Online, version 25 or later |

## Need help with this app?

[Midstream Integrations](https://www.MidstreamIntegrations.com) installs, adapts and supports these extensions, and builds new ones for your process.
**[Book a 20-minute call](https://midstreamintegrations.com/book)** · intro@MidstreamIntegrations.com

## Contributing

Issues and pull requests are welcome; see [CONTRIBUTING](https://github.com/Midstream-Integrations/.github/blob/main/CONTRIBUTING.md).
Found a security problem? Please follow the [security policy](https://github.com/Midstream-Integrations/.github/blob/main/SECURITY.md) instead of opening a public issue.

## License

[MIT](LICENSE) © Midstream Integrations
