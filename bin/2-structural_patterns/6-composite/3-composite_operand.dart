import '1-arithmetic_exp.dart';

class CompositeOperand extends ArithmeticExpression {
  late ArithmeticExpression firstExp;
  late ArithmeticExpression secondExp;
  late String sign;

  CompositeOperand(this.firstExp, this.sign, this.secondExp);

  @override
  double getValue() {
    switch (sign) {
      case '+':
        return firstExp.getValue() + secondExp.getValue();
      case '-':
        return firstExp.getValue() - secondExp.getValue();
      case '*':
        return firstExp.getValue() * secondExp.getValue();
      case '/':
        return firstExp.getValue() / secondExp.getValue();
      default:
        return 0;
    }
  }
}
