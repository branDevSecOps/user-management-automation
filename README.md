# 🧑‍💻 Linux User & Group Management Automation

This project automates the creation of Linux user accounts, group assignments, SSH key setup, and account status management using a CSV input file. It logs all actions, supports dry runs for safe previews, and is designed for easy integration with onboarding or infrastructure setup workflows.

---

## 📁 Project Structure
```
user-manager/
├── user_create.sh           # Main script (DRY_RUN mode supported)
├── users.csv                # Input file (username, group, ssh_key, status)
├── logs/                    # Output logs directory
│   └── user-creation-YYYYMMDD.log
├── .gitignore               # Ignores logs and artifacts
└── README.md                # Project documentation
```

---

## 📄 CSV Format
The script reads from `users.csv` with the following format:

```csv
username,group,ssh_key,status
alice,developers,ssh-rsa AAAAB3...ACTIVE
bob,admins,,LOCKED
carol,developers,ssh-rsa AAAAB3...ACTIVE
```

### Fields:
- `username`: The new user's name
- `group`: The group the user should be added to
- `ssh_key`: Optional public SSH key for secure login
- `status`: Either `ACTIVE` (sets temp password + expire) or `LOCKED`

---

## ⚙️ Script Features
- 🧾 Reads structured CSV input
- 👤 Creates users and groups idempotently
- 🔐 Deploys SSH keys to `~/.ssh/authorized_keys`
- 🔏 Sets permissions correctly for security
- 🗝️ Optionally sets a default password or locks the account
- 🧪 **Dry Run Mode** (`DRY_RUN=true`) for safe previews
- 🪵 Logs all actions to `logs/`

---

## ✅ How to Use
1. Fill out `users.csv`
2. Run the script:
```bash
chmod +x user_create.sh
./user_create.sh
```
3. Check log:
```bash
cat logs/user-creation-*.log
```
4. To perform actual changes, set `DRY_RUN=false` in the script.

---

## 🔐 Security Note
- SSH keys must be valid and securely stored
- Default password is temporary (`TempP@ss123`) and expires on first login
- Accounts can be provisioned but kept locked until ready

---

## 🚀 Future Improvements
- Add support for remote CSV fetching (e.g. from S3 or Git)
- LDAP/AD integration
- Password complexity configuration
- GUI frontend or web form importer

---

Created with ❤️ by Brandon Lester  
[Brandevops YouTube Channel](https://youtube.com/@brandevops)

