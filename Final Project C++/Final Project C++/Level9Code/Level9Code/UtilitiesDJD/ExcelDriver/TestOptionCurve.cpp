// TestSingleCurve.cpp
//
// Displaying a single curve on one Excel sheet.
//
// Modification dates:
//
// 2007-3-3 DD Kick-offs
// 2007-7-23 DD Some schemes (e.g. IE added)
// 2007-7-27 DD derivative-free scheme
// 2009-6-14 DD clean up
// 2012-1-17 DD for QN
// 2017-3-14 DD Lite version
//
// (C) Datasim Education BV 2005-2017
//

#include "ExcelDriverLite.hpp"
#include "Utilities.hpp"
#include "OptionDataFiles/GlobalFunctions.hpp"
#include "OptionDataFiles/Option.cpp"
#include "OptionDataFiles/EuropeanOption.cpp"
#include <cmath>
#include <list>
#include <string>
#include <vector>
using namespace GERALD::OPTIONS;
int main()
{
	// Create abscissa x array
	long N = 40;
	double A = 0.0;  double B = 120.0;
	auto vectorParameter = CreateMesh(N, A, B);

	// create vector of call Prices for 
	// Batch 1: T = 0.25, K = 65, sig = 0.30, r = 0.08, S = 60 (then C = 2.13337, P = 5.84628)
	// Batch 1: T = 0.25, K = 65, sig = 0.30, r = 0.08, S = 60 (then C = 2.13337, P = 5.84628).
	// Batch 2 : T = 1.0, K = 100, sig = 0.2, r = 0.0, S = 100 (then C = 7.96557, P = 7.96557).
	// Batch 3 : T = 1.0, K = 10, sig = 0.50, r = 0.12, S = 5 (C = 0.204058, P = 4.07326).
	// Batch 4 : T = 30.0, K = 100.0, sig = 0.30, r = 0.08, S = 100.0 (C = 92.17570, P = 1.24750).

	double T = 0.25, K = 65, sigma = 0.30, r = 0.08, S = 60, b = r;
	Batch batch1 = { r, sigma, K, T, b, "Call", "Stock", S };
	Batch batch2 = { r = 0.0, sigma = 0.2, K = 100, T = 1.0, b = r, "Call", "Stock", S = 100 };
	Batch batch3 = { r = 0.12, sigma = 0.5,  K = 10.0, T = 1.0, b = r, "Call", "Stock", S = 5.0 };
	Batch batch4 = { r = 0.08, sigma = 0.3, K = 100.0, T = 30.0, b = r, "Call", "Stock", S = 100.0 };

	//
	auto vec1 = vectorPricer(vectorParameter, "S", &EuropeanOption::Pricer, batch1);
	auto vec2 = vectorPricer(vectorParameter, "S", &EuropeanOption::Pricer, batch2);
	auto vec3 = vectorPricer(vectorParameter, "S", &EuropeanOption::Pricer, batch3);
	auto vec4 = vectorPricer(vectorParameter, "S", &EuropeanOption::Pricer, batch4);
	// Names of each vector

	// C++11 syntax:
	//std::list<std::string> labels{ "log(x+0.01)", "x^2", "x^3", "exp(x)","x" };
	std::list<std::string> labels;
	labels.push_back("batch1");
	labels.push_back("batch2");
	labels.push_back("batch3");
	labels.push_back("batch4");

	// The list of Y values

	// C++11 syntax:
	// std::list<std::vector<double> > curves{ vec1, vec2, vec3, vec4, vec5 };
	std::list<std::vector<double> > curves;
	curves.push_back(vec1);
	curves.push_back(vec2);
	curves.push_back(vec3);
	curves.push_back(vec4);

	std::cout << "Data has been created\n";


	ExcelDriver xl; xl.MakeVisible(true);
	xl.CreateChart(vectorParameter, labels, curves, "Comparing batches", "Spot Prices", "Option Prices");

	// Two Curves
	// Multi Curves

	return 0;
}
