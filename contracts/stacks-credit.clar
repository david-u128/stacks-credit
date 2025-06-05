;; Title: StacksCredit Protocol
;; Author: StacksCredit Team
;;
;; Summary:
;; A decentralized credit scoring and lending protocol built on Stacks,
;; enabling Bitcoin-backed loans with dynamic interest rates based on credit history.
;;
;; Description:
;; This smart contract implements a fully on-chain credit scoring system where users 
;; can build their credit history through responsible borrowing. The protocol allows 
;; users to request collateralized loans with interest rates that decrease as their 
;; credit score improves. Successful repayments increase credit scores while defaults 
;; result in penalties, creating a self-reinforcing system of financial responsibility.
;; All collateral is secured through Bitcoin-compatible STX tokens.

;; Constants

;; Contract administration
(define-constant CONTRACT-OWNER tx-sender)

;; Error codes
(define-constant ERR-UNAUTHORIZED (err u1))
(define-constant ERR-INSUFFICIENT-BALANCE (err u2))
(define-constant ERR-INVALID-AMOUNT (err u3))
(define-constant ERR-LOAN-NOT-FOUND (err u4))
(define-constant ERR-LOAN-DEFAULTED (err u5))
(define-constant ERR-INSUFFICIENT-SCORE (err u6))
(define-constant ERR-ACTIVE-LOAN (err u7))
(define-constant ERR-NOT-DUE (err u8))
(define-constant ERR-INVALID-DURATION (err u9))
(define-constant ERR-INVALID-LOAN-ID (err u10))

;; Credit score thresholds
(define-constant MIN-SCORE u50) ;; Minimum possible credit score
(define-constant MAX-SCORE u100) ;; Maximum possible credit score
(define-constant MIN-LOAN-SCORE u70) ;; Minimum score required for loan eligibility

;; Data Maps

;; Stores user credit profiles
(define-map UserScores
  { user: principal }
  {
    score: uint,
    total-borrowed: uint,
    total-repaid: uint,
    loans-taken: uint,
    loans-repaid: uint,
    last-update: uint,
  }
)

;; Stores individual loan data
(define-map Loans
  { loan-id: uint }
  {
    borrower: principal,
    amount: uint,
    collateral: uint,
    due-height: uint,
    interest-rate: uint,
    is-active: bool,
    is-defaulted: bool,
    repaid-amount: uint,
  }
)

;; Maps users to their active loans
(define-map UserLoans
  { user: principal }
  { active-loans: (list 20 uint) }
)

;; Variables

;; Auto-incrementing loan ID counter
(define-data-var next-loan-id uint u0)

;; Tracks total STX locked as collateral
(define-data-var total-stx-locked uint u0)