import '../models/about_us_models.dart';

class AboutUsRepository {
  Future<AboutUsContent> fetchAboutContent() async {
    // Two-stage loading improves perceived smoothness for complex pages.
    await Future.delayed(const Duration(milliseconds: 220));

    final content = AboutUsContent(
      project: const ProjectProfile(
        appName: 'Farmy',
        tagline:
            'A cross-platform digital agriculture platform connecting farmers, investors, and buyers.',
        summary:
            'FarmyApp digitizes fragmented agricultural workflows into one coordinated ecosystem where operations, trust, finance, and commerce move together.',
        mission:
            'Build transparent and scalable agriculture experiences by unifying land workflows, commerce, verification, and collaboration for every actor in the value chain.',
        architecture:
            'Modular Flutter architecture with Provider-based state management and clear separation across screens, models, providers, services, and utilities.',
        stack:
            'Flutter 3.x, Dart 3.x, Provider, Firebase, Stripe, ML Vision tools, and cross-platform deployment targets.',
      ),
      capabilities: const [
        'Identity lifecycle with secure authentication and 2FA support',
        'Land and rental lifecycle modeling for agricultural operations',
        'Product marketplace with basket and order workflows',
        'Wallet, subscriptions, and integrated payment rails',
        'Delivery orchestration for customer and vendor-delivery flows',
        'Proof request lifecycle for trust and compliance visibility',
      ],
      milestones: const [
        AboutMilestone(
          title: 'Multi-Role Core',
          description:
              'Unified customer, farmer, investor, and worker experiences in one application foundation.',
        ),
        AboutMilestone(
          title: 'Trust Layer',
          description:
              'Added verification and proof-request workflows to strengthen transparency for remote stakeholders.',
        ),
        AboutMilestone(
          title: 'Financial Layer',
          description:
              'Integrated subscriptions, wallet capabilities, and payment channels for monetization readiness.',
        ),
      ],
      team: const [
        TeamMember(
          name: 'Karim Feki',
          role: 'Full-Stack Product Engineer',
          focusAreas: ['Architecture', 'Mobile', 'Backend Integration'],
          behanceName: 'Karim Feki',
        ),
        TeamMember(
          name: 'Nesrine Derouiche',
          role: 'Product and Experience Engineer',
          focusAreas: ['UX Flows', 'Quality', 'Feature Design'],
          behanceName: 'Nesrine Derouiche',
        ),
        TeamMember(
          name: 'Mohamed Abidi',
          role: 'Platform and Delivery Engineer',
          focusAreas: ['Operations', 'Performance', 'Reliability'],
          behanceName: 'Mohamed Abidi',
        ),
        TeamMember(
          name: 'Oussema Issaoui',
          role: 'Backend and Integration Engineer',
          focusAreas: ['APIs', 'Data Flows', 'Infrastructure'],
          behanceName: 'Oussema Issaoui',
        ),
        TeamMember(
          name: 'Fatma Hidoussi',
          role: 'Product and Verification Engineer',
          focusAreas: ['Verification', 'User Journeys', 'Testing'],
          behanceName: 'Fatma Hidoussi',
        ),
      ],
      contactDirectory: const ContactDirectory(
        github: [
          ContactLink(
            label: '@fekikarim',
            value: 'github.com/fekikarim',
            url: 'https://github.com/fekikarim',
          ),
          ContactLink(
            label: '@nesrine77',
            value: 'github.com/nesrine77',
            url: 'https://github.com/nesrine77',
          ),
          ContactLink(
            label: '@HamaBTW',
            value: 'github.com/HamaBTW',
            url: 'https://github.com/HamaBTW',
          ),
          ContactLink(
            label: '@oussemissaoui',
            value: 'github.com/oussemissaoui',
            url: 'https://github.com/oussemissaoui',
          ),
          ContactLink(
            label: '@fatmahidouss',
            value: 'github.com/fatmahidouss',
            url: 'https://github.com/fatmahidouss',
          ),
        ],
        linkedIn: [
          ContactLink(
            label: 'Karim Feki',
            value: 'linkedin.com/in/karimfeki',
            url: 'https://www.linkedin.com/in/karimfeki/',
          ),
          ContactLink(
            label: 'Nesrine Derouiche',
            value: 'linkedin.com/in/nesrine-derouiche',
            url: 'https://www.linkedin.com/in/nesrine-derouiche/',
          ),
          ContactLink(
            label: 'Mohamed Abidi',
            value: 'linkedin.com/in/med-abidi',
            url: 'https://www.linkedin.com/in/med-abidi/',
          ),
          ContactLink(
            label: 'Fatma Hidoussi',
            value: 'linkedin.com/in/fatma-hidoussi-497052236',
            url: 'https://www.linkedin.com/in/fatma-hidoussi-497052236/',
          ),
        ],
        email: [
          ContactLink(
            label: 'Karim Feki',
            value: 'feki.karim28@gmail.com',
            url: 'mailto:feki.karim28@gmail.com',
          ),
          ContactLink(
            label: 'Nesrine Derouiche',
            value: 'nesrine.derouiche15@gmail.com',
            url: 'mailto:nesrine.derouiche15@gmail.com',
          ),
          ContactLink(
            label: 'Mohamed Abidi',
            value: 'abidi.mohamed.business@gmail.com',
            url: 'mailto:abidi.mohamed.business@gmail.com',
          ),
          ContactLink(
            label: 'Oussema Issaoui',
            value: 'oussema.issaoui@esprit.tn',
            url: 'mailto:oussema.issaoui@esprit.tn',
          ),
          ContactLink(
            label: 'Fatma Hidoussi',
            value: 'hidoussifatma01@gmail.com',
            url: 'mailto:hidoussifatma01@gmail.com',
          ),
        ],
      ),
      license: const LicenseInfo(
        title: 'Farmy Application License',
        type: 'MIT License',
        summary:
            'Farmy is distributed under the MIT License, allowing broad use, modification, and distribution with attribution and license inclusion.',
        highlights: [
          'Commercial and private use are allowed.',
          'Modification and redistribution are allowed.',
          'The original copyright notice and license text must be included.',
          'Software is provided as-is without warranty.',
        ],
        fullText: '''MIT License

Copyright (c) 2026 Farmy Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.''',
      ),
    );

    await Future.delayed(const Duration(milliseconds: 180));
    return content;
  }
}
