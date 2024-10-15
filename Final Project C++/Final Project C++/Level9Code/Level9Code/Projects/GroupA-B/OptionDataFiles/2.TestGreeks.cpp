/*
1.testGreeks.cpp
In this source file I answer all questions related to Greeks in part A
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
	std::cout << "----------------------------------- Question a) ---------------------------------------------\n";
	// K = 100, S = 105, T = 0.5, r = 0.1, b = 0 and sig = 0.36. (exact delta call = 0.5946, delta put = -0.3566)
	double K = 100, S = 105, T = 0.5, r = 0.1, b = 0, sigma = 0.36;
	Batch batch5(r, sigma, K, T, b, "Call", "Stock", S); // I create a new batch5 to use it later
	EuropeanOption call(r, sigma, K, T, b, "Call", "Stock");
	EuropeanOption put(r, sigma, K, T, b, "Put", "Stock");
	std::cout << "Call Delta: " << call.Delta(S) << endl;
	std::cout << "Put Delta: " << put.Delta(S) << endl;

	std::cout << "\n----------------------------------- Question b) ---------------------------------------------\n";
	vector<double> vectorSpot = Sequence(80.0, 110.0, 5.0);
	std::cout << "Vector of Call Delta for different Spot: " << endl;
	Print(vectorPricer(vectorSpot,"S", &EuropeanOption::Delta, batch5));

	std::cout << "\n----------------------------------- Question c) ---------------------------------------------\n";
	std::cout << "This question can be responded by using the defined vectorPrice where we only use a different parameter vector: " << endl;

	vector<double> vectorExpiryTime = Sequence(0.01, 1.0, 0.05);
	std::cout << "Vector of Call Deltas for different Maturity: " << endl;
	Print(vectorPricer(vectorExpiryTime, "T", &EuropeanOption::Delta, batch5));
	std::cout << "\nVector of Call Gammas for different Maturity: " << endl;
	Print(vectorPricer(vectorExpiryTime, "T", &EuropeanOption::Gamma, batch5));
	std::cout << endl;
	std::cout << "However, we can also apply the matrixPricer global function that takes as input a matrix of parameters and "
		"the result is a vector of option Gammas or Deltas" << endl;
	Batch batch6(r, sigma, K, 0.6, b, "Call", "Stock", S);
	Batch batch7(r, sigma, K, 0.7, b, "Call", "Stock", S);
	Batch batch8(r, sigma, K, 0.8, b, "Call", "Stock", S);
	vector<Batch> matrixParameter = { batch5, batch6, batch7, batch8 };
	Print(matrixPricer(matrixParameter, &EuropeanOption::Pricer));

	std::cout << "\n----------------------------------- Question d) ---------------------------------------------\n";
	double h = 0.001;
	std::cout << "Delta approximation is: " << call.DeltaApproximation(S, h) << ", which is similar to the exact solution: " << call.Delta(S) << endl;
	std::cout << "Gamma approximation is: " << call.GammaApproximation(S, h) << ", which is similar to the exact solution: " << call.Gamma(S) << endl;
	std::cout << endl;
	std::cout << "Now we can also apply the matrixGreekApproximation that takes as input two vector of Spot price and h values and "
		"the result is a matrix of approximation of Gammas and Deltas: " << endl;
	std::vector<double> vectorH = Sequence(0.001, 0.01, 0.001);
	Print(matrixGreeksApproximation(vectorSpot, vectorH, "Delta", call));
	Print(matrixGreeksApproximation(vectorSpot, vectorH, "Gamma", call));
}