class AboutUsContent {
  final ProjectProfile project;
  final List<String> capabilities;
  final List<AboutMilestone> milestones;
  final List<TeamMember> team;
  final ContactDirectory contactDirectory;
  final LicenseInfo license;

  const AboutUsContent({
    required this.project,
    required this.capabilities,
    required this.milestones,
    required this.team,
    required this.contactDirectory,
    required this.license,
  });
}

class ProjectProfile {
  final String appName;
  final String tagline;
  final String summary;
  final String mission;
  final String architecture;
  final String stack;

  const ProjectProfile({
    required this.appName,
    required this.tagline,
    required this.summary,
    required this.mission,
    required this.architecture,
    required this.stack,
  });
}

class AboutMilestone {
  final String title;
  final String description;

  const AboutMilestone({required this.title, required this.description});
}

class TeamMember {
  final String name;
  final String role;
  final List<String> focusAreas;
  final String behanceName;

  const TeamMember({
    required this.name,
    required this.role,
    required this.focusAreas,
    required this.behanceName,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class ContactDirectory {
  final List<ContactLink> github;
  final List<ContactLink> linkedIn;
  final List<ContactLink> email;

  const ContactDirectory({
    required this.github,
    required this.linkedIn,
    required this.email,
  });
}

class ContactLink {
  final String label;
  final String value;
  final String url;

  const ContactLink({
    required this.label,
    required this.value,
    required this.url,
  });
}

class LicenseInfo {
  final String title;
  final String type;
  final String summary;
  final List<String> highlights;
  final String fullText;

  const LicenseInfo({
    required this.title,
    required this.type,
    required this.summary,
    required this.highlights,
    required this.fullText,
  });
}
