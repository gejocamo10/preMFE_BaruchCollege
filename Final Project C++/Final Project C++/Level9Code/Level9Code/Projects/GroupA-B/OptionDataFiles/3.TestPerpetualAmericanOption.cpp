/*
1.testPerpetualAmericanOption.cpp
In this source file I answer all questions related to Perpetual American Option in part A
*/
#include "Option.hpp"
#include "EuropeanOption.hpp"
#include "PerpetualAmericanOption.hpp"
#include "GlobalFunctions.hpp"
using namespace std;
using namespace std;
using namespace GERALD::OPTIONS;
using namespace std;
int main()
{
	cout << "\n----------------------------------- Question b) ---------------------------------------------\n";
	//Test the data with K = 100, sig = 0.1, r = 0.1, b = 0.02, S = 110 (check C = 18.5035, P = 3.03106
	double K = 100, sigma = 0.1, r = 0.1, b = 0.02, S = 110, T = 0.0;
	Batch batch9(r, sigma, K, T, b, "Call", "Stock", S);
	PerpetualAmericanOption call(r, sigma, K, T, b, "Call", "Stock");
	PerpetualAmericanOption put(r, sigma, K, T, b, "Put", "Stock");
	std::cout << "The result for the call is ";
	cout << call.Pricer(S) << endl;
	std::cout << "The result for the put is ";
	cout << put.Pricer(S) << endl;

	cout << "\n----------------------------------- Question c) ---------------------------------------------\n";
	std::vector<double> vectorSpot = Sequence(80.0, 120.0, 5.0);
	std::cout << "I used the vectorPricer to find different prices for different Spot input parameter: " << endl;
	Print(vectorSpot, vectorPricer(vectorSpot, "S", &PerpetualAmericanOption::Pricer, batch9));

	cout << "\n----------------------------------- Question d) ---------------------------------------------\n";
	std::vector<double> vectorSigma = Sequence(0.0, 1.0, 0.1);
	std::cout << "As before, I used first vectorPricer for a new set of sigma parameters: " << endl;
	Print(vectorSigma, vectorPricer(vectorSigma, "sigma", &PerpetualAmericanOption::Pricer, batch9));
	std::cout << "But I also used matrixPricer: " << endl;
	Batch batch10(r, 0.2, K, T, b, "Call", "Stock", S);
	Batch batch11(r, 0.3, K, T, b, "Call", "Stock", S);
	Batch batch12(r, 0.4, K, T, b, "Call", "Stock", S);
	vector<Batch> matrixParameter = { batch9, batch10, batch11, batch12 };
	Print(matrixPricer(matrixParameter, &PerpetualAmericanOption::Pricer));
}
