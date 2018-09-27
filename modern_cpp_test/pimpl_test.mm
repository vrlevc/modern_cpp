//
//  pimpl_test.m
//  modern_cpp_test
//
//  Created by Viktor Levchenko on 9/25/18.
//  Copyright © 2018 LVA. All rights reserved.
//

#import <XCTest/XCTest.h>

#include <memory>

using namespace std;

// MARK: - Widget.h

class Widget
{
public:
	Widget();
	~Widget();		// !!! DELARATION ONLY !!!
	
	// This class is greate candidate for MOVE support !!!
	Widget(Widget&&);				// We have to hide compiler generated implementaions in *.cpp
	Widget& operator=(Widget&&);	// to avoid necessaty of information about Imple struct.
	
	// To suppot copy - we have to manualy do deep copy (unique_ptr perfoms shallow copy)
	Widget(const Widget&);				// Declaration only
	Widget& operator=(const Widget&);	// Hide details in cpp.
	
private:
	struct Impl; // Just declaration
	unique_ptr<Impl> pImpl;	// use smart pointer instead of war one
};

// MARK: - Widget.cpp

#include <string>
#include <vector>
// #include other private for widget impl headers:

struct Widget::Impl	// defeintion of Widget::Impl
{					// with data members for widget
	Impl(int a, double b) {}
	string title;
	string name;
	vector<double>	data;
};

Widget::Widget()
: pImpl( make_unique<Impl>(1, 2.0) )	// use placement ctor!!!
{}

Widget::~Widget() = default;	// !!! HIDE compiler generated destructor in cpp file.	!!!
								// !!! Details for deleting Impl are hidden here.		!!!

Widget::Widget(Widget&&) = default;
Widget& Widget::operator=(Widget&&) = default;

Widget::Widget(const Widget& w) : pImpl( make_unique<Impl>( *w.pImpl ) ) {}
Widget& Widget::operator=(const Widget& w) { *pImpl = *w.pImpl; return *this; }

// MARK: -

@interface pimpl_test : XCTestCase

@end

@implementation pimpl_test

// MARK: - TESTS

- (void)testPimpl
{
	// !!! We can include just widget.h without details about Widget::Imple structure
	// !!! And create object of widget !!!!
	// !!! Widget::~Widget is hidden in *.cpp file and it is still compiler generated !!!
	
// #include "widget.h"
	
	Widget w;
	
}

@end
