/*
1.testExactSolutions.cpp
In this source file I answer all questions related to Exact Solutions in part A
*/
#include "Option.hpp"
#include "EuropeanOption.hpp"
#include "PerpetualAmericanOption.hpp"
#include "GlobalFunctions.hpp"
using namespace std;
using namespace std;
using namespace GERALD::OPTIONS;
int main()
{
	//std::cout << "----------------------------------- Question a) ---------------------------------------------\n";
	////Batch 1: T = 0.25, K = 65, sig = 0.30, r = 0.08, S = 60 (then C = 2.13337, P = 5.84628).
	//double T = 0.25, K = 65, sigma = 0.30, r = 0.08, S = 60, b = r;
	//Batch batch1 = { r, sigma, K, T, b, "Call", "Stock", S};
	//EuropeanOption call_batch1(r, sigma, K, T, b, "Call", "Stock");
	//EuropeanOption put_batch1(r, sigma, K, T, b, "Put", "Stock");
	//std::cout << "Batch1: the price of call is " << call_batch1.Pricer(S) << " and the price of put is " << put_batch1.Pricer(S);

	////Batch 2 : T = 1.0, K = 100, sig = 0.2, r = 0.0, S = 100 (then C = 7.96557, P = 7.96557).
	//T = 1.0, K = 100, sigma = 0.2, r = 0.0, S = 100, b = r;
	//Batch batch2 = { r, sigma, K, T, b, "Call", "Stock", S};
	//EuropeanOption call_batch2(r, sigma, K, T, b, "Call", "Stock");
	//EuropeanOption put_batch2(r, sigma, K, T, b, "Put", "Stock");
	//std::cout << "\nBatch2: the price of call is " << call_batch2.Pricer(S) << " and the price of put is " << put_batch2.Pricer(S);

	////Batch 3 : T = 1.0, K = 10, sig = 0.50, r = 0.12, S = 5 (C = 0.204058, P = 4.07326).
	//T = 1.0, K = 10.0, sigma = 0.5, r = 0.12, S = 5.0, b = r;
	//Batch batch3 = { r, sigma, K, T, b, "Call", "Stock", S};
	//EuropeanOption call_batch3(r, sigma, K, T, b, "Call", "Stock");
	//EuropeanOption put_batch3(r, sigma, K, T, b, "Put", "Stock");
	//std::cout << "\nBatch2: the price of call is " << call_batch3.Pricer(S) << " and the price of put is " << put_batch3.Pricer(S);

	////Batch 4 : T = 30.0, K = 100.0, sig = 0.30, r = 0.08, S = 100.0 (C = 92.17570, P = 1.24750).
	//T = 30.0, K = 100.0, sigma = 0.3, r = 0.08, S = 100.0, b = r;
	//Batch batch4 = { r, sigma, K, T, b, "Call", "Stock", S};
	//EuropeanOption call_batch4(r, sigma, K, T, b, "Call", "Stock");
	//EuropeanOption put_batch4(r, sigma, K, T, b,  "Put", "Stock");
	//std::cout << "\nBatch2: the price of call is " << call_batch4.Pricer(S) << " and the price of put is " << put_batch4.Pricer(S) << endl;

	//std::cout << "\n---------------------------------- Question b) ---------------------------------------------\n";
	//std::vector<Batch> matrixParameter = { batch1, batch2, batch3, batch4 };
	//std::cout << "First approach: "; 
	//std::cout << "For batch 1: The put price using put - call parity is :" << call_batch1.PutCallParity_calculate(std::get<7>(batch1)) << "\nwhich is the same as " 
	//	<< "the call by using exact formula: " << put_batch1.Pricer(std::get<7>(batch1)) << endl;
	//std::cout << "This mean that we can apply the same function to all batches such that we obtain the puts showed in previous question: " << endl;
	//Print(matrixPricer(matrixParameter, &EuropeanOption::PutCallParity_calculate));
	//std::cout << "\nSecond approach: Now we can check if the put-call parity holds for a given call and put prices by using the same overloaded member function. ";
	//call_batch1.PutCallParity_check(std::get<7>(batch1),put_batch1);

	//std::cout << "\n------------------------------ Question c) ---------------------------------------------\n";
	//std::vector<double> vectorSpot = Sequence(30.0, 65.0, 5.0);
	//Print(vectorSpot, vectorPricer(vectorSpot, "S", &EuropeanOption::Pricer, batch1));

	//std::cout << "\n------------------------------ Question d) ---------------------------------------------\n";
	//std::cout << "This question can be responded by using the defined vectorPrice where we only use a different parameter vector: " << endl;
	//std::vector<double> vectorExpiryTime = Sequence(0.0, 1.0, 0.05);
	//Print(vectorExpiryTime, vectorPricer(vectorExpiryTime, "T", &EuropeanOption::Pricer, batch1));
	//std::cout << "However, I also designed a matrixPricer function that take as input a matrix of parameters and "
	//	"the result is a vector of option prices" << endl;
	//Print(matrixPricer(matrixParameter, &EuropeanOption::Pricer));

	//Find the Price, Delta, and Gamma of a European Put with the following parameter, using the Exact method :
	//Spot:  102
	//Strike : 122
	//r = 4.5 %
	//T = 1.65
	//sig = .43
	//b = 0
	double T = 1.65, K = 122, sigma = 0.43, r = 0.045, S = 102, b = r;
	Batch batch1 = { r, sigma, K, T, b, "Put", "Stock", S};
	EuropeanOption put_batch1(batch1);
	std::cout << "The price: " << put_batch1.Pricer(S) << endl;
	std::cout << "The Delta: " << put_batch1.Delta(S) << endl;
	std::cout << "The Gamma: " << put_batch1.Gamma(S) << endl;

	

	return 0;

}