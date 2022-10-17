import '1-arithmetic_exp.dart';
import '2-numeric_operand.dart';
import '3-composite_operand.dart';

void main() {
  ArithmeticExpression exp1 = NumericOperand(3);
  ArithmeticExpression exp2 =
      CompositeOperand(NumericOperand(3), '+', NumericOperand(2));
  ArithmeticExpression exp3 = CompositeOperand(exp1, '*', exp2);
  print(exp2.getValue());
}
