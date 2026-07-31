# A Visual Guide to iOS Code Signing & Provisioning

Code signing answers **who made this app**. Provisioning answers **what it may do and where it may run**.

---

## 1. The mental model

Three pieces, one job each. The profile is the glue.

```mermaid
graph TD
    subgraph APP["APP TARGET, what is being signed"]
        A1["Bundle identifier<br/>com.example.MyApp"]
        A2["Entitlements<br/>.entitlements file"]
    end

    subgraph CERT["CERTIFICATE, who signs it"]
        C1["Signing identity<br/>issued by Apple"]
        C2["Private key<br/>in the keychain"]
    end

    subgraph PROF["PROVISIONING PROFILE, the connector"]
        P1["App ID"]
        P2["Allowed certificates"]
        P3["Allowed entitlements"]
        P4["Distribution type"]
        P5["Devices, if needed"]
    end

    A1 -->|"must match"| P1
    A2 -->|"must be allowed by"| P3
    C1 -->|"must be listed in"| P2
    C1 --- C2

    classDef blue fill:#12439c,stroke:#0a2a66,color:#ffffff,stroke-width:2px
    classDef red fill:#a3170f,stroke:#6b0f09,color:#ffffff,stroke-width:2px
    classDef green fill:#0f5c28,stroke:#093d1a,color:#ffffff,stroke-width:2px
    class A1,A2 blue
    class C1,C2 red
    class P1,P2,P3,P4,P5 green

    style APP fill:#dbe6fb,stroke:#12439c,color:#0a2a66,stroke-width:2px
    style CERT fill:#fadedb,stroke:#a3170f,color:#6b0f09,stroke-width:2px
    style PROF fill:#d7ecdd,stroke:#0f5c28,color:#093d1a,stroke-width:2px
```

> If any one of these is out of sync, Xcode cannot sign the app or iOS refuses to install it.

---

## 2. The four things that must match

```mermaid
graph LR
    B["Bundle identifier"] === P1["App ID in profile"]
    C["Certificate"] === P2["Certificates allowed by profile"]
    E["App entitlements"] === P3["Entitlements allowed by profile"]
    W["Build / distribution workflow"] === P4["Profile type"]

    classDef blue fill:#12439c,stroke:#0a2a66,color:#ffffff,stroke-width:2px
    classDef red fill:#a3170f,stroke:#6b0f09,color:#ffffff,stroke-width:2px
    classDef amber fill:#7a4a00,stroke:#523100,color:#ffffff,stroke-width:2px
    classDef purple fill:#4f2278,stroke:#341551,color:#ffffff,stroke-width:2px
    classDef green fill:#0f5c28,stroke:#093d1a,color:#ffffff,stroke-width:2px
    class B blue
    class C red
    class E amber
    class W purple
    class P1,P2,P3,P4 green
```

Every **extension target** repeats this whole checklist with its own bundle identifier, App ID, and profile.

---

## 3. Certificates and where the private key lives

```mermaid
graph TD
    START["Certificate category"] --> DEV["Development<br/>run and debug on devices"]
    START --> DIST["Distribution<br/>TestFlight, App Store, Ad Hoc"]

    DEV --> LOCAL["Stored locally"]
    DIST --> LOCAL
    DIST --> CLOUD["Cloud-managed by Apple<br/>signed through Xcode Organizer"]

    LOCAL --> KEY{"Is the matching<br/>private key present?"}
    KEY -->|"Yes"| OK["Signing works"]
    KEY -->|"No"| FAIL["Signing fails<br/>copying only the .cer file is not enough"]

    classDef blue fill:#12439c,stroke:#0a2a66,color:#ffffff,stroke-width:2px
    classDef green fill:#0f5c28,stroke:#093d1a,color:#ffffff,stroke-width:2px
    classDef red fill:#a3170f,stroke:#6b0f09,color:#ffffff,stroke-width:2px
    classDef amber fill:#7a4a00,stroke:#523100,color:#ffffff,stroke-width:2px
    class START,DEV,DIST,LOCAL,CLOUD blue
    class KEY amber
    class OK green
    class FAIL red
```

---

## 4. App IDs and capabilities

The App ID is where capabilities get switched on in the developer account. The profile only allows the entitlements the App ID supports.

```mermaid
graph LR
    BID["Bundle identifier<br/>com.example.MyApp"] --> AID["App ID<br/>in Apple Developer account"]
    AID --> CAP["Enabled capabilities"]
    CAP --> C1["Push Notifications"]
    CAP --> C2["Associated Domains"]
    CAP --> C3["App Groups"]
    CAP --> C4["iCloud"]
    CAP --> C5["Sign in with Apple"]
    CAP --> PROF["Profile allows<br/>matching entitlements"]
    PROF --> SIGNED["Entitlements embedded<br/>in the signed app"]

    classDef blue fill:#12439c,stroke:#0a2a66,color:#ffffff,stroke-width:2px
    classDef green fill:#0f5c28,stroke:#093d1a,color:#ffffff,stroke-width:2px
    classDef amber fill:#7a4a00,stroke:#523100,color:#ffffff,stroke-width:2px
    class BID,SIGNED blue
    class AID,PROF green
    class CAP,C1,C2,C3,C4,C5 amber
```

---

## 5. Profile types

```mermaid
graph TD
    R["Provisioning profile<br/>.mobileprovision"] --> D["Development"]
    R --> H["Ad Hoc"]
    R --> S["App Store"]
    R --> I["In-House<br/>Enterprise Program only"]

    D --> D1["Run and debug on devices"]
    D --> DEVLIST["Includes a device list"]
    H --> H1["Distribute to registered devices"]
    H --> DEVLIST
    S --> S1["App Store and TestFlight"]
    S --> NODEV["No device list"]
    I --> I1["Internal employees only,<br/>MDM or secure internal system"]
    I --> NODEV

    classDef green fill:#0f5c28,stroke:#093d1a,color:#ffffff,stroke-width:2px
    classDef blue fill:#12439c,stroke:#0a2a66,color:#ffffff,stroke-width:2px
    classDef amber fill:#7a4a00,stroke:#523100,color:#ffffff,stroke-width:2px
    classDef purple fill:#4f2278,stroke:#341551,color:#ffffff,stroke-width:2px
    class R green
    class D,H,S,D1,H1,S1 blue
    class I,I1 purple
    class DEVLIST,NODEV amber
```

---

## 6. Enterprise (In-House) signing

Enterprise signing is the same three-piece model, with one difference that changes everything downstream. **The profile has no device list and no App Store review**, so a signed build installs on any device that trusts the organization.

That power is why Apple gates it behind a separate program. The Apple Developer Enterprise Program costs $299/year, the organization must be a legal entity with 100 or more employees (no DBAs, trade names, or branches), and the apps must be proprietary, internal-use apps distributed only to employees. It is explicitly meant for cases the App Store, Apple Business Manager custom apps, Ad Hoc, and TestFlight cannot cover.

```mermaid
graph TD
    NEED{"Who needs to install<br/>the app?"}
    NEED -->|"The public"| APPSTORE["Standard program<br/>App Store profile"]
    NEED -->|"A known organization<br/>that is not yours"| CUSTOM["Custom Apps via<br/>Apple Business Manager"]
    NEED -->|"A handful of test devices"| ADHOC["Ad Hoc profile<br/>registered devices"]
    NEED -->|"Your own employees,<br/>at scale"| ENT["Apple Developer<br/>Enterprise Program"]

    ENT --> ECERT["In-House distribution certificate<br/>+ private key"]
    ECERT --> EPROF["In-House provisioning profile<br/>no device list"]
    EPROF --> ESIGN["Sign the app<br/>same matching rules as before"]
    ESIGN --> EDIST{"Delivery channel"}
    EDIST -->|"MDM"| MDM["Pushed to managed devices<br/>implicitly trusted, the org-device<br/>relationship already exists"]
    EDIST -->|"Web"| WEB["HTTPS-hosted manifest plist<br/>itms-services install link"]
    WEB --> TRUST["User approves the provisioning profile in<br/>Settings, General, VPN and Device Management"]
    MDM --> LAUNCH
    TRUST --> LAUNCH["First launch of any in-house app,<br/>the device must get positive confirmation<br/>from Apple that the app may run"]
    LAUNCH --> RUN["Runs on the devices the organization<br/>authorizes via the profile,<br/>no UDID list to maintain"]

    classDef purple fill:#4f2278,stroke:#341551,color:#ffffff,stroke-width:2px
    classDef blue fill:#12439c,stroke:#0a2a66,color:#ffffff,stroke-width:2px
    classDef amber fill:#7a4a00,stroke:#523100,color:#ffffff,stroke-width:2px
    classDef green fill:#0f5c28,stroke:#093d1a,color:#ffffff,stroke-width:2px
    class NEED,EDIST amber
    class APPSTORE,CUSTOM,ADHOC blue
    class ENT,ECERT,EPROF,ESIGN,MDM,WEB,TRUST purple
    class LAUNCH amber
    class RUN green
```

Two details are easy to get backwards. The Settings approval is **not** universal, since MDM-installed apps skip it because the organization-device relationship is already established. The Apple confirmation on first launch **is** universal, MDM or not, which means an in-house app needs a working network path on its very first run. Organizations can also block users from approving apps from unknown developers entirely, leaving MDM as the only viable channel.

### What changes compared to App Store signing

| | App Store | Ad Hoc | In-House (Enterprise) |
| --- | --- | --- | --- |
| Program | Apple Developer, $99/yr | Apple Developer, $99/yr | Apple Developer Enterprise, $299/yr |
| Audience | Anyone | Registered test devices | Own employees only |
| Device list in profile | No | Yes | No |
| App Review | Yes | No | No |
| Delivery | App Store / TestFlight | Ad Hoc install | MDM or hosted manifest |
| Extra user step | None | None | Approve the profile in Settings, unless installed via MDM |
| First-launch network check | No | No | Yes, always |

### The failure modes that are unique to Enterprise

```mermaid
graph TD
    E["In-House signing risks"] --> R1["Profile expiry<br/>1 year, every installed copy<br/>stops launching until re-signed"]
    E --> R2["Certificate expiry<br/>3 years, same blast radius<br/>across every app signed with it"]
    E --> R3["Certificate revocation by Apple<br/>for misuse, kills all installs at once"]
    E --> R4["Leaked private key<br/>anyone can sign apps as your company"]
    E --> R5["No TestFlight<br/>versioning and rollout are your problem"]

    classDef red fill:#a3170f,stroke:#6b0f09,color:#ffffff,stroke-width:2px
    classDef amber fill:#7a4a00,stroke:#523100,color:#ffffff,stroke-width:2px
    class E red
    class R1,R2,R3,R4,R5 amber
```

The practical consequence is simple. Treat the In-House certificate and private key like production secrets, keep the renewal dates on a calendar, and plan a re-sign-and-redistribute path before you need it.

> The expiry windows and revocation behaviour above are operational experience rather than quotes from Apple's security documentation. Confirm the current validity periods in your own developer account before building a renewal schedule on them.

---

## 7. Automatic vs. manual signing

```mermaid
graph TD
    Q{"Who manages the<br/>signing assets?"}
    Q -->|"Xcode"| AUTO["Automatic signing"]
    Q -->|"You"| MAN["Manual signing"]

    AUTO --> A1["Pick a team,<br/>tick 'Automatically manage signing'"]
    AUTO --> A2["Xcode creates and updates<br/>App IDs, certificates, profiles"]
    AUTO --> A3["Adding a capability updates<br/>the App ID and profile for you"]
    AUTO --> A4["Best for local development<br/>and ordinary projects"]

    MAN --> M1["Choose profile and certificate<br/>per target and configuration"]
    MAN --> M2["Predictable assets for CI"]
    MAN --> M3["Tighter team control"]
    MAN --> M4["Different bundle IDs<br/>per configuration"]
    MAN --> M5["Multiple targets or extensions"]
    MAN --> M6["You must regenerate profiles after<br/>new capabilities, devices, or App ID changes"]

    classDef green fill:#0f5c28,stroke:#093d1a,color:#ffffff,stroke-width:2px
    classDef blue fill:#12439c,stroke:#0a2a66,color:#ffffff,stroke-width:2px
    classDef amber fill:#7a4a00,stroke:#523100,color:#ffffff,stroke-width:2px
    classDef purple fill:#4f2278,stroke:#341551,color:#ffffff,stroke-width:2px
    class Q purple
    class AUTO,A1,A2,A3,A4 green
    class MAN,M1,M2,M3,M4,M5 blue
    class M6 amber
```

Enterprise builds are usually signed manually, or with an explicitly pinned profile in CI, because the release depends on one specific In-House identity rather than whatever Xcode would pick.

---

## 8. What happens at signing time

```mermaid
flowchart TD
    BUILD["Build product"] --> COMBINE["Xcode combines build product +<br/>signing identity + provisioning profile"]
    IDENTITY["Signing identity<br/>certificate + private key"] --> COMBINE
    PROFILE["Provisioning profile"] --> COMBINE

    COMBINE --> CHK1{"Bundle ID matches App ID?"}
    CHK1 -->|"No"| ERR["Signing or installation fails"]
    CHK1 -->|"Yes"| CHK2{"Certificate in profile?"}
    CHK2 -->|"No"| ERR
    CHK2 -->|"Yes"| CHK3{"Entitlements allowed?"}
    CHK3 -->|"No"| ERR
    CHK3 -->|"Yes"| CHK4{"Profile type fits<br/>the workflow?"}
    CHK4 -->|"No"| ERR
    CHK4 -->|"Yes"| EXT{"Any extensions?"}
    EXT -->|"Yes"| REPEAT["Repeat every check<br/>for each extension target"]
    REPEAT --> DONE["Signed app"]
    EXT -->|"No"| DONE

    classDef blue fill:#12439c,stroke:#0a2a66,color:#ffffff,stroke-width:2px
    classDef amber fill:#7a4a00,stroke:#523100,color:#ffffff,stroke-width:2px
    classDef green fill:#0f5c28,stroke:#093d1a,color:#ffffff,stroke-width:2px
    classDef red fill:#a3170f,stroke:#6b0f09,color:#ffffff,stroke-width:2px
    class BUILD,IDENTITY,PROFILE,COMBINE,REPEAT blue
    class CHK1,CHK2,CHK3,CHK4,EXT amber
    class DONE green
    class ERR red
```

### What the system checks at launch

Signing correctly is only half the story. iOS requires that all executable code be signed with an Apple-issued certificate, and at launch it validates the code signature of every dynamic library the process links against, so the app's own frameworks and its extensions are checked too, not just the main binary.

The mechanism is the **Team ID**, a 10-character alphanumeric string, for example `1A2B3C4D5F`, extracted from the Apple-issued certificate.

```mermaid
graph TD
    LAUNCHAPP["App launches"] --> LINK{"Which library is<br/>being linked?"}
    LINK -->|"Ships with the system"| OKSYS["Allowed"]
    LINK -->|"Same Team ID as<br/>the main executable"| OKTEAM["Allowed"]
    LINK -->|"Different Team ID"| BLOCK["Blocked, protects the process<br/>from loading third-party code"]

    NOTE["System executables carry no Team ID,<br/>so they can only link against<br/>libraries that ship with the system"]

    classDef blue fill:#12439c,stroke:#0a2a66,color:#ffffff,stroke-width:2px
    classDef amber fill:#7a4a00,stroke:#523100,color:#ffffff,stroke-width:2px
    classDef green fill:#0f5c28,stroke:#093d1a,color:#ffffff,stroke-width:2px
    classDef red fill:#a3170f,stroke:#6b0f09,color:#ffffff,stroke-width:2px
    class LAUNCHAPP blue
    class LINK amber
    class OKSYS,OKTEAM green
    class BLOCK red
    class NOTE blue
```

This is why every embedded framework and extension has to come out of the same signing setup. A mismatch here fails at launch on the device, long after the build succeeded.

---

## 9. Troubleshooting decision tree

```mermaid
flowchart TD
    S["Signing problem"] --> Q1{"What is the symptom?"}

    Q1 -->|"Profile does not include<br/>a signing certificate"| F1["The selected certificate is not part of the profile.<br/>Common after regenerating certificates<br/>or switching machines."]
    Q1 -->|"Capability not supported<br/>by the profile"| F2["The App ID or profile lacks the entitlement.<br/>Enable the capability, then regenerate<br/>and re-download the profile."]
    Q1 -->|"Installs on one device<br/>but not another"| F3["The development or Ad Hoc profile<br/>is missing that device.<br/>Register the device and update the profile."]
    Q1 -->|"CI fails, local build works"| F4["CI is likely missing the private key,<br/>the profile, or access to automatic signing.<br/>Install the assets, or grant CI permission via<br/>Xcode or App Store Connect."]
    Q1 -->|"In-house app stops launching<br/>for everyone at once"| F5["The In-House profile or certificate expired,<br/>or the certificate was revoked.<br/>Re-sign with valid assets and redistribute."]
    Q1 -->|"Untrusted Enterprise Developer<br/>on a web-installed app"| F6["The profile has not been approved yet.<br/>Settings, General, VPN and Device Management.<br/>MDM-installed apps never show this, and the org<br/>may block approving unknown developers entirely."]
    Q1 -->|"In-house app fails only<br/>on its very first launch"| F7["Every in-house app needs positive confirmation<br/>from Apple on first launch.<br/>Check the device's network path, MDM or not."]

    classDef red fill:#a3170f,stroke:#6b0f09,color:#ffffff,stroke-width:2px
    classDef amber fill:#7a4a00,stroke:#523100,color:#ffffff,stroke-width:2px
    classDef green fill:#0f5c28,stroke:#093d1a,color:#ffffff,stroke-width:2px
    classDef purple fill:#4f2278,stroke:#341551,color:#ffffff,stroke-width:2px
    class S red
    class Q1 amber
    class F1,F2,F3,F4 green
    class F5,F6,F7 purple
```

---

## Summary in one line each

| Piece | Question it answers |
| --- | --- |
| Certificate | Who signs the app |
| App ID | Which app this is |
| Entitlements | What the app wants to do |
| Provisioning profile | Which combinations are allowed, and where the app can run |

**Automatic signing** hands most of this to Xcode. **Manual signing** gives more control, at the cost of keeping certificates, profiles, entitlements, bundle identifiers, and devices in sync yourself. **Enterprise signing** is manual signing with a much larger blast radius when something expires.

---

> **Source.** These diagrams are based on the article *Understanding code signing and provisioning in iOS* by tanaschita.com.
> <https://tanaschita.com/ios-code-signing-provisioning>
>
> She did an excellent job of explaining how signing works but I wanted to make a visual representation of it.
> She also has two great iOS books that I highly recommend, <https://tanaschita.com/books/>
>
> The Enterprise (In-House) section and the launch-time validation notes are not from the article. Details on the Apple Developer Enterprise Program come from Apple's program page, <https://developer.apple.com/programs/enterprise/>
>
> Mandatory code signing, Team ID library validation, and in-house app verification follow Apple Platform Security, "App code signing process in iOS, iPadOS, tvOS, visionOS, and watchOS."
