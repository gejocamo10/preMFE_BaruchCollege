/*
Option.cpp
Source file of the abstract class Option
Class that represents method and attributes of options. This is an implementation using basic C++ syntax only.
*/
#include "Option.hpp"
namespace GERALD
{
	namespace OPTIONS
	{
		// Constructors and Destructor
		Option::Option() :
			m_r(0.1), m_sigma(0.01), m_K(50.0), m_T(0.5), m_b(0.1), m_optionType("Call"), m_nameAsset("Stock") {}

		Option::Option(double r, double sigma, double K, double T, double b, string optionType, string nameAsset) :
			m_r(r), m_sigma(sigma), m_K(K), m_T(T), m_b(b), m_optionType(optionType), m_nameAsset(nameAsset)
		{
			if (optionType == "c" || optionType == "C" || optionType == "call") // If m_optionType is "c", "C" or "call", convert the variable into "Call"
				m_optionType = "Call";

			if (optionType == "p" || optionType == "P" || optionType == "put") // If m_optionType is "p", "P" or "put", convert the variable into "Put"
				m_optionType = "Put";
		}

		Option::Option(const Option& source) :
			m_r(source.m_r), m_sigma(source.m_sigma), m_K(source.m_K), m_T(source.m_T), m_b(source.m_b),
			m_optionType(source.m_optionType), m_nameAsset(source.m_nameAsset) {}

		Option::~Option() {}

		// Member operator overloading
		Option& Option::operator=(const Option& source)
		{
			if (this == &source) // if it is the same object, keep it
			{
				return *this;
			}
			m_r = source.m_r;
			m_sigma = source.m_sigma;
			m_K = source.m_K;
			m_T = source.m_T;
			m_optionType = source.m_optionType;
			m_nameAsset = source.m_nameAsset;
			return *this;
		}

		// Other functions
		std::vector<double> Option::d(double S) const
		{
			double d1, d2;
			double tmp = m_sigma * sqrt(m_T);
			if (m_optionType == "Call")
			{
				d1 = (log(S / m_K) + (m_b + (m_sigma * m_sigma) * 0.5) * m_T) / tmp; // calculate d1 for BS pricing
				d2 = d1 - tmp; // calculate d2
			}
			if (m_optionType == "Put") // calculate the same for Put
			{
				d1 = (log(S / m_K) + (m_b + (m_sigma * m_sigma) * 0.5) * m_T) / tmp;
				d2 = d1 - tmp;
			}
			std::vector<double> d = { d1, d2 };
			return d;
		}

		std::vector<double> Option::y() const
		{
			double y1, y2;
			// Calculate y1 for Perpetual American Options
			y1 = (1.0 / 2.0) - (m_b / pow(m_sigma, 2.0)) + pow(pow((m_b / pow(m_sigma, 2.0)) - 1.0 / 2.0, 2.0) + (2.0 * m_r / pow(m_sigma, 2)), 0.5);
			// Calculate y2 for Perpetual American Options
			y2 = (1.0 / 2.0) - (m_b / pow(m_sigma, 2.0)) - pow(pow((m_b / pow(m_sigma, 2.0)) - 1.0 / 2.0, 2.0) + (2.0 * m_r / pow(m_sigma, 2)), 0.5);
			std::vector<double> y = { y1,y2 };
			return y;
		}


	}
}

