import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          _privacyText,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}

const String _privacyText = '''
Privacy Policy

Status: 14 January 2026


1. Introduction

With this privacy policy, we inform you about the processing of personal data when using this mobile application ("Travel Tracker App"). Personal data means any information relating to an identified or identifiable natural person.


2. Controller

Christian Sautner
Scharnhorststraße 41a
04275 Leipzig
Germany

Email: christian.sautner@outlook.de


3. Types of Data Processed

- Contact data (e.g. email address)
- Usage data (e.g. app interactions, feature usage)
- Location data (only if explicitly enabled by the user)
- Technical data (device type, operating system)
- Log and metadata


4. Purposes of Processing

- Providing and improving the mobile application
- Saving visited cities and ratings
- Displaying maps and geographic information
- Analyzing app usage for optimization purposes
- Ensuring security and stability of the app


5. Legal Bases (GDPR)

- Consent (Art. 6(1)(a) GDPR)
- Contract performance (Art. 6(1)(b) GDPR)
- Legal obligation (Art. 6(1)(c) GDPR)
- Legitimate interests (Art. 6(1)(f) GDPR)


6. Security Measures

We implement appropriate technical and organizational measures to protect personal data against unauthorized access, loss, or misuse, considering the state of the art and the nature of processing.


7. Data Transfers & International Transfers

Personal data may be processed by service providers (e.g. hosting, analytics). Transfers to third countries (e.g. USA) are safeguarded by the EU-US Data Privacy Framework (DPF) and/or Standard Contractual Clauses approved by the European Commission.


8. Data Retention

Personal data is deleted as soon as it is no longer required for its original purpose or legal retention obligations apply.


9. Rights of Data Subjects

You have the following rights under GDPR:

- Right of access (Art. 15)
- Right to rectification (Art. 16)
- Right to erasure (Art. 17)
- Right to restriction (Art. 18)
- Right to data portability (Art. 20)
- Right to object (Art. 21)
- Right to withdraw consent at any time
- Right to lodge a complaint with a supervisory authority


10. Cookies

This app may use technically necessary storage mechanisms and identifiers to ensure functionality and security. If analytics services are activated, consent will be obtained where required.


11. Analytics (Google Analytics – optional)

This app may use Google Analytics to analyze app usage on a pseudonymous basis.

Provider:
Google Ireland Limited
Gordon House, Barrow Street
Dublin 4, Ireland

Processed data may include:
- Usage data
- Device information
- Approximate location (country/city level)

IP addresses are anonymized before storage. Data transfers to the USA are safeguarded via the EU-US Data Privacy Framework and Standard Contractual Clauses.

Privacy Policy:
https://policies.google.com/privacy

Opt-out:
https://tools.google.com/dlpage/gaoptout


12. Google Maps

This app uses Google Maps SDK to display geographic information. Processing may include IP address and location data.

Provider:
Google Cloud EMEA Limited
Dublin, Ireland

Privacy Policy:
https://policies.google.com/privacy


13. Updates to This Policy

We may update this privacy policy to reflect legal or technical changes. The current version is always available within the app.
''';
