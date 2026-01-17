class PolicyAction {
  final String id;
  final String name;
  final String description;
  final int cost;

  const PolicyAction({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
  });
}

const List<PolicyAction> kPolicyActions = [
  PolicyAction(
    id: 'social',
    name: 'Social Support',
    description: 'Boosts happiness this turn, drains budget in future turns.',
    cost: 20,
  ),
  PolicyAction(
    id: 'enforce',
    name: 'Enforcement Push',
    description: 'Deploys control across districts; instant order, delayed trust erosion.',
    cost: 20,
  ),
  PolicyAction(
    id: 'infra',
    name: 'Infrastructure',
    description: 'Builds systems slowly; productivity compounds over many turns.',
    cost: 25,
  ),
  PolicyAction(
    id: 'intel',
    name: 'Intelligence',
    description: 'Expands visibility into hidden systems; future events become clearer.',
    cost: 15,
  ),
  PolicyAction(
    id: 'emergency',
    name: 'Emergency Response',
    description: 'Rapid crisis intervention; uses reserves to stabilize critical meters.',
    cost: 30,
  ),
  PolicyAction(
    id: 'stimulus',
    name: 'Economic Stimulus',
    description: 'Short-term productivity spike; long-term inflation and corruption risk.',
    cost: 35,
  ),
  PolicyAction(
    id: 'surveillance',
    name: 'Surveillance Intensity',
    description: 'Tracks underground activity and reduces uncertainty; erodes trust.',
    cost: 25,
  ),
];
