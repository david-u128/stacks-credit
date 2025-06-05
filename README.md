# StacksCredit Protocol

A decentralized credit scoring and lending protocol built on Stacks, enabling Bitcoin-backed loans with dynamic interest rates based on credit history.

## Overview

StacksCredit Protocol implements a fully on-chain credit scoring system where users build their credit history through responsible borrowing. The protocol offers collateralized loans with interest rates that decrease as credit scores improve, creating a self-reinforcing system of financial responsibility secured by STX tokens.

## Key Features

- **Dynamic Credit Scoring**: On-chain credit scores that improve with successful loan repayments
- **Risk-Adjusted Pricing**: Interest rates decrease as credit scores increase
- **Collateral Management**: Secure STX-based collateral with score-based requirements
- **Loan Lifecycle Management**: Complete loan origination, repayment, and default handling
- **Transparent History**: All credit history stored immutably on-chain

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    StacksCredit Protocol                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌──────────────┐ │
│  │   User Scores   │    │     Loans       │    │ User Loans   │ │
│  │                 │    │                 │    │              │ │
│  │ • Credit Score  │    │ • Loan Details  │    │ • Active     │ │
│  │ • Loan History  │    │ • Collateral    │    │   Loan IDs   │ │
│  │ • Repayment     │    │ • Status        │    │              │ │
│  │   Track Record  │    │ • Interest Rate │    │              │ │
│  └─────────────────┘    └─────────────────┘    └──────────────┘ │
│           │                       │                     │       │
│           └───────────────────────┼─────────────────────┘       │
│                                   │                             │
│  ┌─────────────────────────────────┼─────────────────────────────┤
│  │             Core Functions      │                             │
│  ├─────────────────────────────────┼─────────────────────────────┤
│  │ • initialize-score()            │ • repay-loan()              │
│  │ • request-loan()                │ • mark-loan-defaulted()     │
│  │ • calculate-interest-rate()     │ • update-credit-score()     │
│  │ • calculate-required-collateral()                             │
│  └─────────────────────────────────────────────────────────────┘
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Credit Scoring System

### Score Range
- **Minimum Score**: 50
- **Maximum Score**: 100
- **Minimum Loan Eligibility**: 70

### Score Mechanics
- **Initial Score**: 50 (upon initialization)
- **Successful Repayment**: +2 points
- **Loan Default**: -10 points
- **Score Impact**: Affects interest rates and collateral requirements

### Interest Rate Calculation
```
Interest Rate = Base Rate (10%) - (Score × 5% / 100)

Examples:
- Score 70: 6.5% interest rate
- Score 80: 6.0% interest rate  
- Score 90: 5.5% interest rate
- Score 100: 5.0% interest rate
```

### Collateral Requirements
```
Collateral Ratio = 100% - (Score × 50% / 100)

Examples:
- Score 70: 65% collateral ratio
- Score 80: 60% collateral ratio
- Score 90: 55% collateral ratio
- Score 100: 50% collateral ratio
```

## Usage Guide

### For Borrowers

#### 1. Initialize Credit Score
```clarity
(contract-call? .stackscredit initialize-score)
```

#### 2. Request a Loan
```clarity
(contract-call? .stackscredit request-loan 
  u1000000    ;; Amount (1 STX in micro-STX)
  u650000     ;; Collateral (0.65 STX)
  u1440       ;; Duration (1 day in blocks)
)
```

#### 3. Repay Loan
```clarity
(contract-call? .stackscredit repay-loan 
  u1          ;; Loan ID
  u1065000    ;; Repayment amount (principal + interest)
)
```

### For Administrators

#### Mark Defaulted Loans
```clarity
(contract-call? .stackscredit mark-loan-defaulted u1)
```

## Read-Only Functions

### Check User Credit Score
```clarity
(contract-call? .stackscredit get-user-score 'SP1234...)
```

### View Loan Details
```clarity
(contract-call? .stackscredit get-loan u1)
```

### View User's Active Loans
```clarity
(contract-call? .stackscredit get-user-active-loans 'SP1234...)
```

## Data Structures

### UserScores Map
```clarity
{
  score: uint,           ;; Current credit score (50-100)
  total-borrowed: uint,  ;; Lifetime borrowed amount
  total-repaid: uint,    ;; Lifetime repaid amount
  loans-taken: uint,     ;; Number of loans taken
  loans-repaid: uint,    ;; Number of loans successfully repaid
  last-update: uint      ;; Block height of last update
}
```

### Loans Map
```clarity
{
  borrower: principal,   ;; Borrower's address
  amount: uint,          ;; Principal loan amount
  collateral: uint,      ;; Collateral amount locked
  due-height: uint,      ;; Block height when loan is due
  interest-rate: uint,   ;; Interest rate (percentage)
  is-active: bool,       ;; Whether loan is currently active
  is-defaulted: bool,    ;; Whether loan has defaulted
  repaid-amount: uint    ;; Amount repaid so far
}
```

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u1 | ERR-UNAUTHORIZED | Caller not authorized for this action |
| u2 | ERR-INSUFFICIENT-BALANCE | Insufficient balance for operation |
| u3 | ERR-INVALID-AMOUNT | Invalid loan or repayment amount |
| u4 | ERR-LOAN-NOT-FOUND | Specified loan does not exist |
| u5 | ERR-LOAN-DEFAULTED | Loan has already defaulted |
| u6 | ERR-INSUFFICIENT-SCORE | Credit score too low for loan |
| u7 | ERR-ACTIVE-LOAN | Too many active loans (max 5) |
| u8 | ERR-NOT-DUE | Loan not yet due for default |
| u9 | ERR-INVALID-DURATION | Invalid loan duration |
| u10 | ERR-INVALID-LOAN-ID | Invalid loan ID |

## Limits and Constraints

- **Maximum Active Loans**: 5 per user
- **Maximum Loan Duration**: ~1 year (52,560 blocks)
- **Maximum Active Loan IDs**: 20 per user list
- **Minimum Credit Score for Loans**: 70

## Security Considerations

1. **Collateral Safety**: All collateral is held by the contract until loan repayment
2. **Access Control**: Only borrowers can repay their loans
3. **Admin Functions**: Only contract owner can mark loans as defaulted
4. **Validation**: Comprehensive input validation on all parameters
5. **State Consistency**: Atomic operations ensure data integrity

## Deployment Notes

- Contract must be deployed with sufficient STX balance to fund loans
- Consider implementing additional admin functions for protocol management
- Monitor collateral ratios and adjust parameters based on market conditions
- Implement off-chain monitoring for loan due dates and default detection

## License

This smart contract is provided as-is for educational and development purposes. Please review and audit thoroughly before mainnet deployment.

---

*Built with ❤️ on Stacks blockchain*