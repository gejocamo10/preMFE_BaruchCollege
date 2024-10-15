#ifndef GlobalFunctions_hpp
#define GlobalFunctions_hpp
#include <iostream>
#include <sstream>
#include <vector>
#include <map>		
#include <algorithm>
#include <string>

std::vector<double> Sequence(double a, double b, double h) // vector of sequence between number a and by that goes by h
{
	double n_elements = ((b - a) / h) + 1;
	std::vector<double> vector(n_elements);
	a -= h;
	for (size_t i = 0; i < vector.size(); ++i) {
		a += h;
		vector[i] = a;
	}
	return vector;
}

void Print(const std::vector<double>& vectorParameter)
{
	std::cout << "(";
	for (std::size_t i = 0; i < vectorParameter.size(); i++)
	{
		if (i != vectorParameter.size() - 1)
		{
			std::cout << vectorParameter[i] << ",";
		}
		else {
			std::cout << vectorParameter[i];
		}
	}
	std::cout << ")" << endl;
}

void Print(const std::vector<double>& vectorParameter, const std::vector<double>& vectorPrices)
{
	std::cout << "[";
	for (std::size_t i = 0; i < vectorParameter.size(); i++)
	{
		if (i != vectorParameter.size() - 1)
		{
			std::cout << "(" << vectorParameter[i] << "," << vectorPrices[i] << ")" << "," << endl;
		}
		else {
			std::cout << "(" << vectorParameter[i] << "," << vectorPrices[i] << ")";
		}
	}
	std::cout << "]" << endl;
}

void Print(const std::vector<std::vector<double>>& matrix)
{  // A generic print function for vectors

	std::cout << "\n[";
	for (int i = 0; i < matrix.size(); ++i)
	{
		Print(matrix[i]);
	}

	std::cout << "\n";
}

template<typename T, typename B>
std::vector<double> vectorPricer(const std::vector<double>& vectorParameter, string parameter,
	double (T::* PricerFunction)(double) const, const B& batch)
{
	std::vector<double> vectorPrices;
	T Option(batch);
	for (std::size_t i = 0; i < vectorParameter.size(); i++)
	{
		if (parameter == "r") { Option.r(vectorParameter[i]); vectorPrices.push_back((Option.*PricerFunction)(get<7>(batch))); }
		if (parameter == "sigma") { Option.sigma(vectorParameter[i]);vectorPrices.push_back((Option.*PricerFunction)(get<7>(batch))); }
		if (parameter == "K") { Option.K(vectorParameter[i]); vectorPrices.push_back((Option.*PricerFunction)(get<7>(batch))); }
		if (parameter == "T") { Option.T(vectorParameter[i]); vectorPrices.push_back((Option.*PricerFunction)(get<7>(batch))); }
		if (parameter == "b") { Option.b(vectorParameter[i]); vectorPrices.push_back((Option.*PricerFunction)(get<7>(batch))); }
		if (parameter == "S") { vectorPrices.push_back((Option.*PricerFunction)(vectorParameter[i])); }
	}
	return vectorPrices;
}

template<typename T, typename B>
std::vector<double> matrixPricer(const std::vector<B>& matrixParameter, 
	double (T::* PricerFunction)(double) const)
{
	std::vector<double> vectorPrices;
	for (int i = 0; i < matrixParameter.size(); i++)
	{
		T Option(matrixParameter[i]);
		vectorPrices.push_back((Option.*PricerFunction)(std::get<7>(matrixParameter[i])));
	}
	return vectorPrices;
}

template< typename T>
std::vector<std::vector<double>> matrixGreeksApproximation(const std::vector<double>& vectorSpot, const std::vector<double>& vectorH,
	string greek, const T& option)
{
	std::vector<std::vector<double>> matrixGreek(vectorSpot.size());
	T Option(option);
	for (int j = 0; j < vectorSpot.size(); j++)
	{
		for (int i = 0; i < vectorH.size(); i++)
		{
			if (greek == "Delta") { matrixGreek[j].push_back(Option.DeltaApproximation(vectorSpot[j], vectorH[i])); }
			if (greek == "Gamma") { matrixGreek[j].push_back(Option.GammaApproximation(vectorSpot[j], vectorH[i])); }
		}
	}
	return matrixGreek;
}
#endif