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
];
