// BEFORE: An evaluator interprets tags and nullable fields in generic nodes.
class ExpressionNode {
  final double? number;
  final String? operation;
  final List<ExpressionNode> children;
  ExpressionNode.number(double value)
    : number = value,
      operation = null,
      children = [];
  ExpressionNode.operation(this.operation, this.children) : number = null;
}

double evaluate(ExpressionNode node) {
  if (node.number != null) return node.number!;
  if (node.operation == '+') {
    return node.children.fold(0, (sum, child) => sum + evaluate(child));
  }
  if (node.operation == '*') {
    return node.children.fold(1, (product, child) => product * evaluate(child));
  }
  throw ArgumentError('Unknown operation');
}

void main() {
  final expression = ExpressionNode.operation('*', [
    ExpressionNode.operation('+', [
      ExpressionNode.number(3),
      ExpressionNode.number(2),
    ]),
    ExpressionNode.number(4),
  ]);
  print(evaluate(expression));
}
