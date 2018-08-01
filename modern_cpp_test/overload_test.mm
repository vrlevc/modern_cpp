//
//  overload_test.m
//  modern_cpp_test
//
//  Created by Viktor Levchenko on 8/1/18.
//  Copyright © 2018 LVA. All rights reserved.
//

#import <XCTest/XCTest.h>

#include <stdio.h>
#include <vector>

class Hero
{
public:
	using Skills = std::vector<int>;
	
	Hero() : skills {1,2,3,4,5} {}
	Hero(const Hero&) = default;
	Hero(Hero&&) = default;
	~Hero() = default;
	Hero& operator=(const Hero&) = default;
	Hero& operator=(Hero&&) = default;
	
	static Hero CreateHero()
	{
		Hero hero;
		return hero;
	}
	
	Skills& GetSkills() &
	{
		printf(" ->>> GetSkills of lvalue Hero\n");
		return skills;
	}
	
	Skills GetSkills() &&
	{
		printf(" ->>> GetSkills of rvalue Hero\n");
		return std::move(skills);
	}
	
private:
	Skills  skills;
};

// MARK:-

@interface overload_test : XCTestCase
@end

@implementation overload_test

- (void)testHero
{
	Hero hero;
	
	auto skilsA = hero.GetSkills();
	auto skilsB = Hero::CreateHero().GetSkills();
}

@end
