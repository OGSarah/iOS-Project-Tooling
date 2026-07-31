# A Visual Guide to iOS Code Signing & Provisioning

Code signing answers **who made this app**. Provisioning answers **what it may do and where it may run**.

---

## 1. The mental model

Three pieces, one job each. The profile is the glue.

```mermaid
graph TD
    subgraph APP["APP TARGET — what is being signed"]
        A1["Bundle identifier<br/>com.example.MyApp"]
        A2["Entitlements<br/>.entitlements file"]
    end

    subgraph CERT["CERTIFICATE — who signs it"]
        C1["Signing identity<br/>issued by Apple"]
        C2["Private key<br/>in the keychain"]
    end

    subgraph PROF["PROVISIONING PROFILE — the connector"]
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

The App ID is where capabilities get switched on in the developer account — and the profile only allows the entitlements the App ID supports.

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

    D --> D1["Run and debug on devices"]
    D --> DEVLIST["Includes a device list"]
    H --> H1["Distribute to registered devices"]
    H --> DEVLIST
    S --> S1["App Store and TestFlight"]
    S --> S2["No device list —<br/>distribution is not limited to test devices"]

    classDef green fill:#0f5c28,stroke:#093d1a,color:#ffffff,stroke-width:2px
    classDef blue fill:#12439c,stroke:#0a2a66,color:#ffffff,stroke-width:2px
    classDef amber fill:#7a4a00,stroke:#523100,color:#ffffff,stroke-width:2px
    class R green
    class D,H,S,D1,H1,S1 blue
    class DEVLIST,S2 amber
```

---

## 6. Automatic vs. manual signing

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

---

## 7. What happens at signing time

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

---

## 8. Troubleshooting decision tree

```mermaid
flowchart TD
    S["Signing problem"] --> Q1{"What is the symptom?"}

    Q1 -->|"Profile does not include<br/>a signing certificate"| F1["The selected certificate is not part of the profile.<br/>Common after regenerating certificates<br/>or switching machines."]
    Q1 -->|"Capability not supported<br/>by the profile"| F2["The App ID or profile lacks the entitlement.<br/>Enable the capability, then regenerate<br/>and re-download the profile."]
    Q1 -->|"Installs on one device<br/>but not another"| F3["The development or Ad Hoc profile<br/>is missing that device.<br/>Register the device and update the profile."]
    Q1 -->|"CI fails, local build works"| F4["CI is likely missing the private key,<br/>the profile, or access to automatic signing.<br/>Install the assets, or grant CI permission via<br/>Xcode or App Store Connect."]

    classDef red fill:#a3170f,stroke:#6b0f09,color:#ffffff,stroke-width:2px
    classDef amber fill:#7a4a00,stroke:#523100,color:#ffffff,stroke-width:2px
    classDef green fill:#0f5c28,stroke:#093d1a,color:#ffffff,stroke-width:2px
    class S red
    class Q1 amber
    class F1,F2,F3,F4 green
```

---

## Summary in one line each

| Piece | Question it answers |
| --- | --- |
| Certificate | Who signs the app |
| App ID | Which app this is |
| Entitlements | What the app wants to do |
| Provisioning profile | Which combinations are allowed, and where the app can run |

**Automatic signing** hands most of this to Xcode. **Manual signing** gives more control, at the cost of keeping certificates, profiles, entitlements, bundle identifiers, and devices in sync yourself.

---

> **Source:** These diagrams are based on the article *Understanding code signing and provisioning in iOS* by tanaschita.com — <https://tanaschita.com/ios-code-signing-provisioning/?utm_source=substack&utm_medium=email>
