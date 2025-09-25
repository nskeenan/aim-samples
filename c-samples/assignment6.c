// Name: Nicholas Keenan
// Net ID: keenann
// Program Description: This program
//  manages up to 10 savings or checking
//  bank accounts based on user input.

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

// Macros that will be used throughout the
// program.
#define ACC_MAX 10
#define NAME_MAX 30
#define OPEN_DATE_LEN 11

// Creating a type of struct that carries
// all of the initialized information.
// This is used to hold the bank account information.
typedef struct {
    int acc_number;
    char acc_type[8];
    char owner_name[NAME_MAX];
    char open_date[OPEN_DATE_LEN];
    double acc_balance;
} bank_account;

// Initializing global variables.
bank_account total_accounts[ACC_MAX];
int accounter = 0;
int date_checker = 1;

// Introducing function prototypes that
// will be defined after the main function.
// These functions allow the code to function
// as most are used when called in the main menu.
int read_line(char str[], int n);
void tolower_string(char *str);
void account_create();
int acc_number_check(int acc_number);
int open_date_check(const char *open_date);
void money_deposit();
void money_withdraw();
int compare_acc_number(const void *a, const void *b);
int compare_owner_name(const void *a, const void *b);
int compare_open_date(const void *a, const void *b);
int compare_acc_balance(const void *a, const void *b);
void sort_account();
void print_account();

// Main function that introduces the main menu
// that drives the entire program. The switch function
// allows the user to choose a character to run the specific
// function.
int main() {
    char menu;
    while (1) {
        printf("******* Main menu *******\n");
        printf("c(reate an account)\n");
        printf("d(eposit money)\n");
        printf("w(ithdraw money)\n");
        printf("s(sort and print accounts)\n");
        printf("q(uit program)\n");
        printf("*************************\n");
        printf("Enter operation code (c, d, w, s, q): ");
        scanf(" %c", &menu);
        getchar();

        switch (tolower(menu)) {
            case 'c':
                account_create();
                break;
            case 'd':
                money_deposit();
                break;
            case 'w':
                money_withdraw();
                break;
            case 's':
                sort_account();
                print_account();
                break;
            case 'q':
                exit(0);
                break;
            default:
                printf("Invalid option. Try again.\n");
        }
    }
    return 0;
}

// The read_line function cleanly goes through a
// user's input. The program specifically uses this
// when getting a new account's open date. This
// function dodges possible input buffer clogging.
int read_line(char str[], int n) {
    int ch, j = 0;
    while ((ch = getchar()) != '\n') {
    if (j < n) {
        str[j++] = ch;
    }
    }
    str[j] = '\0';
    return j;
}

// The tolower_string function goes through a
// string (usually through user input) and makes
// all characters lowercase. This makes loops easier
// to work with, especially when they deal with menus.
void tolower_string(char *str) {
    for (int j = 0; str[j]; j++) {
        str[j] = tolower((unsigned char)str[j]);
    }
}

// The account_create function uses the main bank_account
// struct and fills all of the information with user information
// relating to a new bank account. All of these are saved during
// the running instance of the program, and can be brought up
// when sorting and printing.
void account_create() {
    if (accounter >= ACC_MAX) {
        printf("You have reached the maximum number of accounts.\n");
        return;
    }

    bank_account new_acc;
    printf("Enter account number (4 digits): ");
    scanf(" %d", &new_acc.acc_number);
    getchar();

    if (!acc_number_check(new_acc.acc_number)) {
        printf("Enter a number between 1000 and 9999.\n");
        return;
    }

    printf("Enter account type: c(hecking), s(avings)\n");
    printf("c or s: ");
    fgets(new_acc.acc_type, sizeof(new_acc.acc_type), stdin);
    new_acc.acc_type[strcspn(new_acc.acc_type, "\n")] = 0;
    tolower_string(new_acc.acc_type);

    if (strcmp(new_acc.acc_type, "c") != 0 && strcmp(new_acc.acc_type, "checking") != 0 &&
        strcmp(new_acc.acc_type, "s") != 0 && strcmp(new_acc.acc_type, "savings") != 0) {
        printf("Wrong account type. Enter c or s.\n");
        return;
    }

    printf("Enter account holder's name: ");
    fgets(new_acc.owner_name, sizeof(new_acc.owner_name), stdin);
    new_acc.owner_name[strcspn(new_acc.owner_name, "\n")] = 0;

    while (1) {
        printf("Enter open date (YYYY-MM-DD): ");
        read_line(new_acc.open_date, sizeof(new_acc.open_date));

        if (open_date_check(new_acc.open_date)) {
            break;
        } else {
            printf("%s Wrong date format.\n", new_acc.open_date);

        }
    }


    printf("Enter balance (number only): $ ");
    scanf("%lf", &new_acc.acc_balance);
    getchar();

    total_accounts[accounter++] = new_acc;
    printf("Account %d is created.\n\n", new_acc.acc_number);
}

// The acc_number_check function is a simple function that
// checks to see if an account number is within a 4 digit
// scope, and was not already used previously.
int acc_number_check(int acc_number) {
    if (acc_number > 9999 || acc_number < 1000) {
        return 0;
    }
    for (int j = 0; j < accounter; j++) {
        if (total_accounts[j].acc_number == acc_number) {
            return 0;
        }
    }
    return 1;
}

// The open_date_check function checks the user inputted
// open date to check for correct digits (a valid date)
// and the correct layout.
int open_date_check(const char *open_date) {
    if (strlen(open_date) != 10) {
        return 0;
    }

    if (open_date[4] != '-' || open_date[7] != '-') {
        return 0;
    }

    int digit_sum = 0;
    for (int i = 0; i < 10; i++) {
        if (i == 4 || i == 7) continue;
        if (!isdigit(open_date[i])) {
            return 0;
        }
        digit_sum += open_date[i] - '0';
    }

    if (digit_sum == 0) {
        return 0;
    }
    return 1;
}

// The money_deposit function looks for an existing
// bank account number based on user input and allows
// the user to add to the dollar amount of that specific
// bank account.
void money_deposit() {
    int acc_number;
    double dollar_amount = 0;
    printf("Enter account number: ");
    scanf("%d", &acc_number);
    getchar();

    for (int j = 0; j < accounter; j++) {
        if (total_accounts[j].acc_number == acc_number) {
            while (dollar_amount <= 0) {
                printf("Enter amount (> 0, number only): $ ");
                scanf("%lf", &dollar_amount);
                getchar();
                if (dollar_amount > 0) {
                    total_accounts[j].acc_balance += dollar_amount;
                    printf("Remaining balance: $ %.2lf\n\n", total_accounts[j].acc_balance);
                    return;
                } else {
                    printf("Amount must be greater than 0.\n");
                }
            }
        }
    }

}

// The money_withdraw function looks for an existing
// bank account number based on user input and allows
// the user to subtract a dollar amount of that specific
// bank account.
void money_withdraw() {
    int acc_number;
    double dollar_amount = 0;
    printf("Enter account number: ");
    scanf("%d", &acc_number);
    getchar();

    for (int j = 0; j < accounter; j++) {
        if (total_accounts[j].acc_number == acc_number) {
            while (dollar_amount <= 0) {
                printf("Enter amount (> 0, number only): $ ");
                scanf("%lf", &dollar_amount);
                getchar();
                if (dollar_amount > 0 && total_accounts[j].acc_balance >= dollar_amount) {
                    total_accounts[j].acc_balance -= dollar_amount;
                    printf("Remaining balance: $ %.2lf\n\n", total_accounts[j].acc_balance);
                    return;
                } else if (dollar_amount <= 0) {
                    printf("Amount must be greater than 0.\n");
                } else {
                    printf("Insufficient balance.\n\n");
                }
            }
        }
    }

}

// The compare_acc_number function is for the sort
// account function. This specific function compares
// the account numbers to see which one would be listed first.
int compare_acc_number(const void *a, const void *b) {
    bank_account *account_a = (bank_account *)a;
    bank_account *account_b = (bank_account *)b;
    return account_a->acc_number - account_b->acc_number;
}

// The compare_owner_name function is for the sort
// account function. This specific function compares
// the account names to see which one would be listed first.
int compare_owner_name(const void *a, const void *b) {
    bank_account *account_a = (bank_account *)a;
    bank_account *account_b = (bank_account *)b;
    return strcmp(account_a->owner_name, account_b->owner_name);
}

// The compare_open_date function is for the sort
// account function. This specific function compares
// the account open dates to see which one would be listed first.
int compare_open_date(const void *a, const void *b) {
    bank_account *account_a = (bank_account *)a;
    bank_account *account_b = (bank_account *)b;
    return strcmp(account_a->open_date, account_b->open_date);
}

// The compare_acc_balance function is for the sort
// account function. This specific function compares
// the account balances to see which one would be listed first.
int compare_acc_balance(const void *a, const void *b) {
    bank_account *account_a = (bank_account *)a;
    bank_account *account_b = (bank_account *)b;
    if (account_a->acc_balance < account_b->acc_balance) return -1;
    if (account_a->acc_balance > account_b->acc_balance) return 1;
    return 0;
}

// The sort_account function sorts the user inputted bank
// accounts based off of the options shown on the sorting menu.
void sort_account() {
    char sort_menu;
    printf("Enter the sorting field: a(ccount number), h(older name), o(pen date), b(alance)\n");
    printf("a, h, o or b: ");
    scanf(" %c", &sort_menu);
    getchar();

    switch (sort_menu) {
        case 'a':
            qsort(total_accounts, accounter, sizeof(bank_account), compare_acc_number);
            break;
        case 'h':
            qsort(total_accounts, accounter, sizeof(bank_account), compare_owner_name);
            break;
        case 'o':
            qsort(total_accounts, accounter, sizeof(bank_account), compare_open_date);
            break;
        case 'b':
            qsort(total_accounts, accounter, sizeof(bank_account), compare_acc_balance);
            break;
        default:
            printf("Invalid option. Try again.\n");
            return;
    }
}

// The print_account function prints the accounts that were just sorted
// based off the user input and choice on the sorting menu.
void print_account() {
    printf("#### Type Holder name                    Open date          Balance\n");
    printf("--------------------------------------------------------------------\n");
    for (int j = 0; j < accounter; j++) {
        printf("%-4d %-4s %-30s %-10s %10.2lf\n", total_accounts[j].acc_number,
               total_accounts[j].acc_type[0] == 'c' ? "C" : "S",
               total_accounts[j].owner_name, total_accounts[j].open_date, total_accounts[j].acc_balance);
    }
    printf("--------------------------------------------------------------------\n\n");
}