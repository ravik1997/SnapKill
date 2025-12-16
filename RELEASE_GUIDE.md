# How to Share SnapKill 📦

There are two main ways to share your app: the **Quick Way** (for yourself/friends) and the **Proper Way** (for the public).

## 1. The Proper Way (Recommended)

This creates an optimized, standalone version of your app.

1.  Open **SnapKill.xcodeproj** in Xcode.
2.  In the top toolbar, verify the destination is set to **Any Mac (Apple Silicon, Intel)** (or "My Mac").
3.  Go to the menu bar: **Product** > **Archive**.
4.  Wait for the build to finish. The "Organizer" window will open.
5.  Select the latest archive and click **Distribute App**.
6.  Choose **Custom** (or "Copy App").
7.  Select **Copy App** to just export the `.app` file.
8.  Save it to your Desktop.
9.  Right-click the `SnapKill.app` and choose **Compress "SnapKill"** to make a `.zip` file.
10. Share this `.zip` file!

## 2. The Quick Way (Debug Build)

If you just want the file you're currently running:

1.  In Xcode, in the Project Navigator (left sidebar), look for the **Products** folder.
2.  Right-click `SnapKill.app`.
3.  Select **Show in Finder**.
4.  Copy that `.app` file, zip it, and share it.

---

## ⚠️ Important Note: The "App is Damaged" Warning

Since you likely haven't paid Apple $99/year for a Developer Certificate to "Notarize" this app, your friends might see this error when they try to open it:

> *"SnapKill" is damaged and can't be opened. You should move it to the Trash.*

This is **Gatekeeper** protecting them from unknown apps. It's not actually damaged.

### The Fix for Users
Tell your friends to run this command in Terminal **one time** after downloading your app:

```bash
xattr -cr /Path/To/SnapKill.app
```

(e.g., `xattr -cr ~/Downloads/SnapKill.app`)


---

## 3. Publishing on GitHub (The Best Way)

**Do not** drag the `.app` file directly into your source code folder and commit it. Git is for code, not large binary files.

Instead, use **GitHub Releases**:

1.  Push your code to GitHub (`git push origin main`).
2.  Go to your repository page on GitHub.com.
3.  Click **Releases** (on the right sidebar) > **Draft a new release**.
4.  Tag version: `v1.0.0`.
5.  Title: "Initial Release".
6.  **Drag and drop** your `SnapKill.zip` file into the "Attach binaries..." box.
7.  Click **Publish release**.

Now anyone can download your app from the "Releases" section without downloading the code!
