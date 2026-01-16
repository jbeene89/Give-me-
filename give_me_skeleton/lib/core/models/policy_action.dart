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
    description: 'Short-term happiness boost, long-term budget drag.',
    cost: 20,
  ),
  PolicyAction(
    id: 'enforce',
    name: 'Enforcement Push',
    description: 'Reduces instability quickly, but can erode trust.',
    cost: 20,
  ),
  PolicyAction(
    id: 'infra',
    name: 'Infrastructure',
    description: 'Slow productivity gains; resilience improves over time.',
    cost: 25,
  ),
  PolicyAction(
    id: 'intel',
    name: 'Intelligence',
    description: 'Improves forecast quality; reduces surprise events later.',
    cost: 15,
  ),
];
