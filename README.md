# DayOff Package

## 📌 Description
The **DayOff** package provides an Apex class and custom metadata to:  
- Check if a given date falls on a **weekend** or a **public holiday**.  
- Validate French public holidays (via external API or custom metadata).  
- Integrate with **Salesforce Flows** through `@InvocableMethod`.  

This package is useful to automate scheduling, prevent bookings on non-working days, and ensure business processes remain consistent.  

---

## 📂 Package Content
- **Main Class**: `API_GetDayOff.cls`  
  - Checks if a date is a weekend or public holiday.  
  - Retrieves public holidays via an external API and stores them in **Custom Metadata Types**.  
  - Exposes an invocable method for Salesforce Flows.  

- **Custom Metadata Type**: `No_Working_Day__mdt`  
  - Stores the list of holidays for a given zone and date.  
  - Includes fields such as: `X1er_janvier__c`, `Lundi_Paques__c`, `Ascension__c`, `Jour_Noel__c`, etc.  

---

## 🌐 Public Holidays API

The package relies on an external API that provides official public holidays.  

### Constraints:
- The API only supports dates from **20 years in the past** up to **5 years in the future** relative to the current year.  
- Example: if today is **2025**, the valid range is **2005 → 2030**.  
- Dates outside this range will **not return results**.  

### Example Callout

| StatusCode | Response  | Meaning                     |
| ---------- | --------- | --------------------------- |
| 200        | OK        | Working day                 |
| -1         | Weekend   | Saturday or Sunday          |
| -1         | Holiday   | Public holiday              |
| 500+       | Error ... | API failure (not reachable) |

---

## 🔧 Installation Guide

### Install package in a **Scratch Org**

1. Enable DevHub in your main org. 
2. Clone the repository
```bash
git clone https://github.com/bbakaryb/DayOff.git
cd DayOff

3. Authenticate a Dev Hub
sf org login web --set-default-dev-hub --alias DevHub

4. Create a Scratch Org
sf org create scratch --definition-file config/project-scratch-def.json --duration-days 30 --alias MyScratchOrg --target-dev-hub DevHub


5. Install the package:
sf package install --wait 10 --publish-wait 10 --package dayoff@1.0.0-1 --installation-key test1234 --no-prompt --target-org MyScratchOrg

6. Open your Scratch Org:
sf org open --target-org MyScratchOrg

### Install package in a **Production or Sandbox Org**

1. Authenticate your target org:
sf org login web --alias MyOrg

4. Install the package:
sf package install --wait 10 --publish-wait 10 --package dayoff@1.0.0-1 --installation-key test1234 --no-prompt --target-org MyOrg

---

## 🛠 Usage
Once installed:
Add the DayOff invocable method to your Salesforce Flows.

Pass a DateTime and a Zone as input.








