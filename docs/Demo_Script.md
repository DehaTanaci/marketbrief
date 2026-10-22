# MarketBrief: Presentation Script (22 October 2026, 13:00)

The teacher's format: **1–2 min** specs + diagram, **3–4 min** live demo, then **1–2 questions**. Total 5–7 minutes, no time for debugging.
Lines in *italics* are things to say. **Bold** is what to type or click.

---

## Before you present

**Tonight (if you want to rehearse)**
- Rehearse the whole thing once, out loud, with a timer.
- After rehearsing, send **/unwatch AIR.PA MC.PA THYAO.IS** so the stocks you add in the demo are new again. Otherwise the bot will say "already on your list".
- The "Yahoo down" step was already rehearsed on 21 October and works. If you rehearse it again on the morning of the demo, do it **at most once**: the backup only allows 25 lookups a day and each backup report uses 6.

**Tomorrow morning**
1. Check that the **8:00 report arrived** in Telegram. Don't delete it: it's step 1 of the demo.
2. Send **/status**. Every line should say ✅ working. If any says 🧪, send **/simulate reset**.
3. Check the Google Sheet for your slot in the presentation order.

**Five minutes before your slot, have these open:**
- The PDF proposal, on page 1.
- Telegram on the laptop (web.telegram.org), scrolled to the 8:00 report. Keep your phone as a backup.
- n8n: the **MR · Build & Send Reports** canvas.
- Supabase (supabase.com, your project): **Table Editor → mr_report_log**.

---

## Part 1: Specs and diagram (1 min 45 s)

**Show PDF page 1.**

*"My project is number 20, the automated dashboard, aimed at Level 3. I call it MarketBrief.*

*The need: people who follow a few stocks open three or four apps every morning (their broker, a currency converter, a news site) and still have to work out what matters to them. With MarketBrief you tell a Telegram bot which companies you follow, once. Then every weekday at 8:00 you get one message: the US indices, your own stocks, the dollar/euro rate, the key headlines, and a short AI summary that's fact-checked before you see it.*

*It has three triggers: a Telegram message, a schedule at 8:00 Paris time, and a manual run for testing."*

**Jump to the last page (the diagram).**

*"There are five workflows. A handles Telegram commands and checks every message before anything touches the database. B builds the reports. It fetches all the data once for everyone, each section can fail without stopping the others, it makes one AI call, and code fact-checks that summary. C fetches prices: Yahoo first, two retries, then Alpha Vantage as a backup, and it stops calling Yahoo after three failures in a row. D turns company names into stock codes. E alerts me on Telegram when something really breaks.*

*The green box is the state: a PostgreSQL database on Supabase with six tables: subscribers, watchlists, every report sent, price history, and the health of each source. The database enforces the key rules itself: nobody can follow the same stock twice, and only one scheduled report per person per day can ever be recorded. Everything outside the dashed line can fail. The design is about what happens when it does.*

*The difference from Lab 1: Lab 1 answers when you ask and then forgets. This comes to you, remembers you, and keeps working when a source breaks. Let me show you."*

---

## Part 2: Live demo (about 3 min 45 s)

### 0:00 · The report that came by itself (45 s)

**Telegram: show this morning's 8:00 report.**

*"This came at 8:00 this morning without me touching anything."* Point at each part from top to bottom:
- *"It says whether prices are live or from yesterday's US close."*
- *"'In short' is written by AI, but it's labelled **fact-checked**. Code checks that every number the AI wrote exists in the real data, and that it gives no buy or sell advice. If the AI invents something, its text is replaced by a summary written by code."*
- *"Then my stocks sorted by how much they moved, the currency rate, and four headlines the AI picked."*

### 0:45 · Break it live (1 min 15 s): the key moment

Type **/simulate yahoo down**

*"This is a hidden switch only I can use. It makes the main price source fail on purpose. If anyone else types it, the bot just says it doesn't understand."*

Type **/report**

"⏳ Preparing your report…" appears **instantly**. The report takes about 25 seconds this time, because the backup is asked for one price every 2 seconds to respect its free limit. While you wait:
*"It answers first and works afterwards, so you never stare at a silent chat. Right now it's trying Yahoo twice, failing, and switching to the backup."*

When the report arrives, point at the line **⚠️ Some prices came from the backup source (Alpha Vantage)…**

*"The report still arrived and it tells me honestly where the prices came from. If everything fails at once, I still get what's left, with a note for each missing section. I tested every failure case in the proposal on the live system."*

Type **/simulate reset**

### 2:00 · It's personal (45 s)

Type **/watch airbus, lvmh, turkish airlines, qwertyzzz**

What appears:
- airbus → **AIR.PA**, lvmh → **MC.PA**
- turkish airlines → **THYAO.IS** *(matched by AI, double-check)*
- ❌ qwertyzzz not found

*"Names are looked up on Yahoo's free search first. The AI is only asked when the search finds nothing, like 'turkish airlines', and even then its answer is re-checked on Yahoo, so the AI can never add a stock that doesn't exist. The fake name is rejected and nothing is saved. There's also a cap of 30 stocks per person."*

### 2:45 · Behind the scenes (45 s)

**Switch to n8n, the Build & Send Reports canvas.** Sweep left to right:
*"Who gets a report, fetch everything with each part allowed to fail, one AI call, the fact-check, one personal message per user, the delivery log. At the end, 'Fail Loudly': if reports were due but nothing was delivered, the run is marked failed so I get alerted, instead of looking green."*

**Switch to the Supabase tab (mr_report_log).**
*"This is the database, on Supabase. Every report sent is logged. That's how it never sends twice: if the morning job runs twice, the second run sees I'm already served today and sends nothing. And you can see which reports used the backup or the code summary."*

### 3:30 · Close (15 s)

*"Every required building block is used, every failure case was tested live, and the limits are in the proposal: Yahoo is unofficial, which is why there's a backup, and the fact-check verifies numbers but not yet whether the AI said 'rose' or 'fell'. Thank you."*

**If you're running long:** cut "Behind the scenes" down to the report log only. Never cut "Break it live": it's the Level 3 proof.

---

## If something goes wrong live

- **The report is slow:** keep talking. *"It's waiting on a data source, which is exactly what the retries and backup handle."* It usually lands within 30 seconds.
- **The bot doesn't answer at all:** don't debug. Scroll up in Telegram to yesterday's test reports (the backup one, the "everything down" one, the 🚨 alert), and open n8n **Executions** to show the dated runs.
- **"You already asked for 5 reports today":** present it as the cost-control feature, then show yesterday's backup report instead.
- **You forgot /simulate reset:** do it right after the demo. Otherwise tomorrow's 8:00 report will use the backup.

---

## The teacher's 1–2 questions: short answers

**"How is this different from Lab 1?"**
Lab 1 answers when asked and forgets. MarketBrief comes on a schedule, remembers each person, serves everyone from one data fetch, and keeps working when sources fail. The AI is one small, checked step, not the engine.

**"Why not let the AI do everything?"**
The AI is unreliable with numbers and costs money per call. Code computes every number, the AI only writes text and picks headlines, once per morning for everyone, and its output is checked before anyone sees it.

**"How do you know the AI didn't invent something?"**
Code pulls every number out of the AI's text and compares it with the real data. If one doesn't match, or it gives advice, the AI text is replaced by a summary written by code. Testing caught this: it once rejected the "500" in "S&P 500", which I fixed.

**"What if Yahoo changes or disappears?"**
Two retries, then Alpha Vantage. After three failed runs in a row, Yahoo is skipped for 30 minutes. If both fail, that section says unavailable and the rest still goes out.

**"What stops a report being sent twice?"**
Every sent report is logged with the date. The morning job checks the log first and skips anyone already served.

**"Why Supabase / PostgreSQL?"**
I started with n8n's built-in tables and moved to a real PostgreSQL database on Supabase. The data now lives outside n8n, so it survives if the n8n account goes away, and the database enforces the important rules itself: a unique key stops duplicate stocks, and a rule allows only one scheduled report per person per day. Row-level security is on, so only n8n's database login can reach the tables. The trade-off: it's one more service that can fail. Reads are retried, and if the database stays down the run fails loudly and I get alerted.

**"What if Supabase goes down?"**
Every database read is retried. If it stays down, the morning run fails on purpose and the error workflow alerts me, because without the database it can't know who to send to. Fetching prices doesn't depend on it.

**"What about cost?"**
One AI call per morning regardless of user count, 5 on-demand reports per person per day, 30 stocks per person, and the backup is only called for what Yahoo couldn't provide.

**"Privacy?"**
/stop deletes everything stored about that person: their stocks, their subscription and their report history.

**"What would you do next?"**
Check that the AI's "rose/fell" matches the numbers, add a weekly recap from the stored price history, and move to Supabase's paid plan for daily backups.

---

## Command cheat sheet

| Type | What happens |
|---|---|
| /start or /help | Welcome message and command list |
| /watch airbus, lvmh | Follow stocks by name (commas) or code (spaces) |
| /unwatch AIR.PA MC.PA | Stop following stocks (uses the codes) |
| /list | Your stocks |
| /report | Your report now (max 5 a day) |
| /status | Health of each data source |
| /simulate yahoo down | Owner only: break a source (yahoo, alphavantage, fx, news, ai) |
| /simulate reset | Everything back to normal |
| /stop | Unsubscribe and delete your data |
