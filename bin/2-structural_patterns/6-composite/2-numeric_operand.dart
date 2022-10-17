import '1-arithmetic_exp.dart';

class NumericOperand extends ArithmeticExpression {
  late double value;

  NumericOperand(this.value);

  @override
  double getValue() {
    return value;
  }

  void setValue(double value) {
    this.value = value;
  }
}
