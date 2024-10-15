// HardCoded.cpp
//
// C++ code to price an option, essential algorithms.
//
// We take CEV model with a choice of the elaticity parameter
// and the Euler method. We give option price and number of times
// S hits the origin.
//
// (C) Datasim Education BC 2008-2011
//

#include "OptionData.hpp" 
#include "UtilitiesDJD/RNG/NormalGenerator.hpp"
#include "UtilitiesDJD/Geometry/Range.cpp"
#include <cmath>
#include <iostream>

template <class T> void print(const std::vector<T>& myList)
{  // A generic print function for vectors
	
	std::cout << std::endl << "Size of vector is " << myList.size() << "\n[";

	// We must use a const iterator here, otherwise we get a compiler error.
	std::vector<T>::const_iterator i;
	for (i = myList.begin(); i != myList.end(); ++i)
	{
			std::cout << *i << ",";

	}

	std::cout << "]\n";
}

std::vector<double> accuracy(const std::vector<double>& vectorPrices, const double& r, const double& T) // Function tu calculate the accuracy of Monte Carlo simulation
{
	double priceOptionSum = 0.0; // Sum of each simulation option prices for SD calculation
	double priceOptionSumSquare = 0.0; // Sum of squares of each simulation option prices for SD calculation
	double NSim = vectorPrices.size(); // Number of simulations
	typename std::vector<double>::const_iterator i;
	for (i = vectorPrices.begin(); i != vectorPrices.end(); ++i)
	{
		priceOptionSum += *i; // sum option prices for Standard Deviation
		priceOptionSumSquare += pow(*i, 2.0); // sum square of option prices for Standard Deviation
	}
	// Stanrdard Deviation
	double SD = pow((priceOptionSumSquare - (pow(priceOptionSum, 2.0)/ NSim)) / (NSim - 1), 0.5) * exp(-r * T); // Standard Deviation
	double SE = SD / pow(NSim, 0.5); // Standard Error
	std::vector<double> vectorResults = { SD,SE }; // vector that save both SD and SE
	return vectorResults;
}

namespace SDEDefinition
{ // Defines drift + diffusion + data

	OptionData* data;				// The data for the option MC

	double drift(double t, double X)
	{ // Drift term
	
		return (data->r)*X; // r - D
	}

	
	double diffusion(double t, double X)
	{ // Diffusion term
	
		double betaCEV = 1.0;
		return data->sig * pow(X, betaCEV);
		
	}

	double diffusionDerivative(double t, double X)
	{ // Diffusion term, needed for the Milstein method
	
		double betaCEV = 1.0;
		return 0.5 * (data->sig) * (betaCEV) * pow(X, 2.0 * betaCEV - 1.0);
	}
} // End of namespace


int main()
{
	//Batch 1: T = 0.25, K = 65, sig = 0.30, r = 0.08, S = 60 (then C = 2.13337, P = 5.84628).
	//Batch 2 : T = 1.0, K = 100, sig = 0.2, r = 0.0, S = 100 (then C = 7.96557, P = 7.96557).
	//Batch 3 : T = 1.0, K = 10, sig = 0.50, r = 0.12, S = 5 (C = 0.204058, P = 4.07326).
	//Batch 4 : T = 30.0, K = 100.0, sig = 0.30, r = 0.08, S = 100.0 (C = 92.17570, P = 1.24750).
	//Spot:  150
	//Strike : 155
	//r = 3 %
	//T = 1.25
	//sig = .25
	//b = r

	std::cout <<  "1 factor MC with explicit Euler\n";
	OptionData myOption;
	myOption.T = 1.25;
	myOption.K = 155.0;
	myOption.sig = 0.25;
	myOption.r = 0.03;
	double S_0 = 150.0;
	myOption.type = 1;	// Put -1, Call +1
	
	long N = 100;
	std::cout << "Number of subintervals in time: ";
	std::cin >> N;

	// Create the basic SDE (Context class)
	Range<double> range (0.0, myOption.T);
	double VOld = S_0;
	double VNew;

	std::vector<double> x = range.mesh(N);
	

	// V2 mediator stuff
	long NSim = 50000;
	std::cout << "Number of simulations: ";
	std::cin >> NSim;

	double k = myOption.T / double (N);
	double sqrk = sqrt(k);

	// Normal random number
	double dW;
	double price = 0.0;	// Option price

	// NormalGenerator is a base class
	NormalGenerator* myNormal = new BoostNormal();

	using namespace SDEDefinition;
	SDEDefinition::data = &myOption;

	std::vector<double> res;
	int coun = 0; // Number of times S hits origin

	// A.
	for (long i = 1; i <= NSim; ++i)
	{ // Calculate a path at each iteration
			
		if ((i/10000) * 10000 == i)
		{// Give status after each 1000th iteration

				std::cout << i << std::endl;
		}

		VOld = S_0;
		for (unsigned long index = 1; index < x.size(); ++index)
		{

			// Create a random number
			dW = myNormal->getNormal();
				
			// The FDM (in this case explicit Euler)
			VNew = VOld  + (k * drift(x[index-1], VOld))
						+ (sqrk * diffusion(x[index-1], VOld) * dW);

			VOld = VNew;

			// Spurious values
			if (VNew <= 0.0) coun++;
		}
			
		double tmp = myOption.myPayOffFunction(VNew);
		price += (tmp)/double(NSim);
		res.push_back(tmp); // return vector of prices for each simulation
	}
	
	// D. Finally, discounting the average price
	price *= exp(-myOption.r * myOption.T);

	// Cleanup; V2 use scoped pointer
	delete myNormal;

	std::cout << "Price, after discounting: " << price << ", " << std::endl;
	std::cout << "Number of times origin is hit: " << coun << endl;
	print(accuracy(res, myOption.r, myOption.T));
	return 0;
}