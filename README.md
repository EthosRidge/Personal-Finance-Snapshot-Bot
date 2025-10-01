# Project: Spend-Tracker-Bot

I built this project for a simple reason: I wanted a super fast, no-nonsense way to know how much "fun money" I had left after all my bills were paid for the month.

I was tired of opening clunky spreadsheets or budgeting apps just to answer one question: "How much can I actually spend freely?" As someone who loves building efficient solutions, I figured, why not create a tool that gives me the answer instantly, right in my terminal?

### The Idea & My Approach

My workflow is straightforward. When I pay off my Chase credit card, I get an email receipt. I simply save that payment amount into a text file in a dedicated folder. That's it. That's the trigger.

This bot watches that folder. The moment it sees a new payment file, it springs into action. It automatically grabs that payment amount, adds it to all my other fixed monthly bills (like rent and internet), subtracts the total from my income, and gives me a clean, simple breakdown of my finances.

I made a deliberate choice **not** to use complex APIs to read my email directly. This approach is faster, far more secure (no need to grant an application access to my inbox), and keeps the project lightweight and focused on doing one job perfectly.

### Key Features

*   ⚡️ **Instant Answer:** Run one command and get the exact number you're looking for. No logins, no waiting, no distractions.
*   🔒 **Private & Secure by Design:** Your financial data never leaves your computer. The bot doesn't connect to your bank, email, or any cloud service.
*   ⚙️ **Simple Configuration:** All your income and recurring bills are stored in a plain `config.json` file. Updating your rent or adding a new subscription is as easy as editing a line of text.
*   🤖 **Real-World Automation:** This is a practical example of "trigger-based automation"—a core concept in modern IT and DevOps, applied to a personal, everyday problem.

This project was a fun way for me to apply my PowerShell scripting skills to make my own life easier. It's a testament to how a little bit of thoughtful automation can solve a real-world problem.

---

### **How It Works: The Technical Breakdown**

1.  **The Brain (`Run-FinanceBot.ps1`):** A well-commented PowerShell script that serves as the engine. It handles file monitoring, calculations, and displaying the output in a clean, readable format.
2.  **The Memory (`config.json`):** A simple JSON file where all personal financial data (income, recurring bills) is stored. This separates the logic from the data, making the tool highly customizable.
3.  **The Trigger (`_inbox` folder):** A designated folder the script watches. Dropping a `.txt` file containing a single number (e.g., `154.78`) kicks off the entire process.
4.  **The Archive (`_processed` folder):** After a payment file is read, it's automatically moved here. This is a crucial step to prevent it from being counted twice.

### **Getting Started**

1.  **Configure:** Open the `config.json` file and update it with your own monthly income and recurring payments.
2.  **Run the Bot:** Execute the `Run-FinanceBot.ps1` script in a PowerShell terminal. It will start watching the `_inbox` folder.
3.  **Log a Payment:** Create a new `.txt` file in the `_inbox` folder. Inside the file, just put the payment amount (e.g., `250.55`) and save it.
4.  **See the Results:** The bot will instantly detect the file, perform the calculations, and display your updated financial summary right in the terminal.