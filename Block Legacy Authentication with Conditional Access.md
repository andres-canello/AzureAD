# Block Legacy Authentication with Conditional Access

Great news! Conditional Access in Azure AD now includes the ability to block Legacy Authentication! Wait, what's wrong with Legacy Authentication? Read on.

What is Legacy Authentication? Generally speaking, this means protocols that use Basic Authentication and typically cannot enforce any type of second factor authentication. On the other hand, Modern Authentication can do second factor authentication, typically, this means that the app can pop up a browser frame so the user can perform whatever is required as second factor. This can be entering a one-time code, approve a push notification on the phone, or answering a phone call.

Examples of protocols that use Legacy Authentication are: POP3, IMAP4, SMTP, etc. There are other protocols that can do Basic Auth and Modern Auth, examples are MAPI, EWS, etc.

## So, what's the problem?
Single factor authentication (i.e.: username and password) is not enough these days. Passwords are bad as they are easy to guess and we (humans) are bad at choosing good passwords and tend to just give them to attackers (phishing anyone?). One of the easiest things that can be done to protect against password threats is implementing multi-factor authentication (MFA). So even if an attacker gets in possession of a user's password, the password alone is not sufficient to successfully authenticate and access the data.

The problem then is what to do with protocols using Legacy Authentication. The recommendation is to just block these protocols or, if you must use them, allow them only for certain users and specific network locations.

Until now, there were 2 ways of blocking Legacy Authentication in Azure AD:

- In Federated environments (i.e.: using AD FS), you could use claim rules to allow certain protocols and deny access to the rest. This gets messy when you need to start adding conditions and exception.
- Enforcing MFA per-user, the effect of this is that users are then forced to use App Passwords for Legacy Auth protocols, however if you disallow its use, you effectively block these protocols. The bad news here is that you can't use any kind of conditions, it's all or nothing.
Another way to block Legacy Auth is doing it server-side (vs at the Identity Provider). For example in Exchange Online, you could disable POP3 or IMAP for the user. There are 2 problems with this, first is that you can't do this for all your users, this is done per-user. Second is that you don't want to block protocols that can do Legacy and Modern Auth (i.e.: EWS, MAPI) as you most likely still need them. There is no way to only block Legacy Auth for those protocols. (spoiler alert: for now)

## What's new in Azure AD to help me with this?
Glad you ask. This month (May 2018) we released 2 new functionalities to help you with this:

- Better sign-in logging: now is faster, gives you more info (Conditional Access evaluation!), device info, and the type of client/protocol/authentication being used. More info [here] (https://docs.microsoft.com/en-us/azure/active-directory/whats-new#view-legacy-authentications-through-sign-ins-activity-logs).
- The ability to use Conditional Access to block Legacy Authentication clients. More info [here] (https://docs.microsoft.com/en-us/azure/active-directory/active-directory-conditional-access-conditions#legacy-authentication).
So, you are telling me that the CA policy I have that requires MFA for all apps and users if they are outside the network is not protecting clients using Legacy Authentication? Yep.

Conditional Access only works with Modern Authentication protocols, this includes all browser-based flows, clients that use Open ID Connect or OAuth, and Exchange ActiveSync, which largely all clients support only with Basic Auth (IOS 11 mail client supports Modern Auth). This was, until now.

Discover what Legacy Authentication protocols/clients are being used across the organisation
For doing this, you will rely on the new Azure AD Sign-in logs.

- Go to the Azure Portal, Azure Active Directory and open the Sign-ins blade.
- Click Columns and select Client App from the list.
- Please note that this works for domains using Federation or Cloud Authentication (Cloud ID, Pass-through Authentication or Password Hash Sync).\

The possible values are: IMAP, MAPI, Older Office Clients (the ones that rely on the Sign In Assistant), POP and SMTP. There is also an Other Clients category, which is a catch-all for everything else.

Use this info to understand what clients/protocols are being used in your organisation, who are the users, and where they are connecting from. If you mostly see Office clients and you have Office 2013 or above, make sure you enable Modern Authentication for them. Here is more info.

## Block Legacy Authentication clients with Conditional Access
Conditional Access now has a new Client App called "Other Clients", this represent Legacy Auth clients (there is a separate client type for Exchange ActiveSync, this is ActiveSync/BasicAuth, clients that support ActiveSync/ModernAuth will fall in the Mobile Apps and Desktop Clients category).

Any condition can be used to narrow the scope of the policies, so make sure you target only a few test users before deploying it broadly. If you still have users using Legacy Auth clients, a first good step would be to allow these clients only from known locations. This will stop attackers from accessing your data if they happen to obtain a user's password.

Any control can be applied to these clients, however, all of them will lead to block as no other controls can be applied to this protocols.

## A final note on what you are protecting with this
By implementing the above policy, you are protecting your data from being accessed with single factor authentication if an attacker happens to guess a user's password.

There are protections in Azure AD to prevent attackers from trying large numbers of passwords for your users. Ultimately these are throttling mechanisms, so attackers will be less likely to guess passwords (specially if you ban common passwords! read this for more info).

This is much easier for them if protocols like POP3 or IMAP are enabled. So ultimately these protocols should be disabled in Exchange Online, so they can be denied right before the auth request is proxied to the Identity Provider (AD FS, Azure AD, etc.). More news to come on this soon (ish).

So there you have it, go ahead and block those spider-web-covered protocols!

Andres Canello - Senior Program Manager, Azure AD.
