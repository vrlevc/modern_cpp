//
//  thread_test.m
//  modern_cpp_test
//
//  Created by Viktor Levchenko on 8/1/18.
//  Copyright © 2018 LVA. All rights reserved.
//

#import <XCTest/XCTest.h>

#include <iostream>
#include <thread>
#include <future>
#include <sstream>
#include <chrono>
#include <array>
#include <list>
#include <string>
#include <algorithm>
#include <vector>

using namespace std::literals;

// MARK: Helpers

template<typename F, typename... Args>
inline
auto really_async(F&& fn, Args&&... args)
{
	return std::async(std::launch::async,
					  std::forward<F>(fn),
					  std::forward<Args>(args)...);
}

class ThreadRAII
{
public:
	enum class DtorAction { join, detach };
	ThreadRAII(std::thread&& t, DtorAction a) : action(a), t(std::move(t)) {}
	~ThreadRAII()
	{
		if (t.joinable())
		{
			action == DtorAction::join ? t.join() : t.detach();
		}
	}
	ThreadRAII(ThreadRAII&&) = default;
	ThreadRAII& operator=(ThreadRAII&&) = default;
	std::thread& get() { return t; }
private:
	DtorAction  action;
	std::thread t;
};

// MARK: Thread functions

static int doPrepare	(std::string tag, int timeOut);
static int doWork		(std::string tag, int timeOut);
static int doAsyncWork	(std::string tag, int timeOut);

// MARK:-

@interface thread_test : XCTestCase
@end

@implementation thread_test

// MARK:-

- (void)setUp
{
	[super setUp];
	std::cout << "--------------------------------------------------------\n";
	//	std::srand(std::time(nullptr));
}

- (void)tearDown
{
	std::cout << "--------------------------------------------------------\n";
}

// MARK:- TEST CASES

- (void)test_main_doAsyncWork
{
	doAsyncWork("MAIN THREAD", 100);
}

- (void)test_thread
{
	std::thread t1( doAsyncWork, "---",  50 );
	std::thread t2( doAsyncWork, "+++", 100 );
	std::thread t3( doAsyncWork, "***", 500 );
	
	t1.join();
	t2.join();
	t3.join();
}

- (void)test_future
{
	auto fut1 = std::async( doAsyncWork, "---",  50 );
	auto fut2 = std::async( doAsyncWork, "+++", 100 );
	auto fut3 = std::async( doAsyncWork, "***", 500 );
}

- (void)test_future_launch_deferred
{
	auto fut1 = std::async( std::launch::deferred, doAsyncWork, "---",  50 );
	auto fut2 = std::async( std::launch::deferred, doAsyncWork, "+++", 100 );
	
	auto constexpr DELAY = 5s;
	std::cout << " ->>> START wating for thread started ... ";
	auto start = std::chrono::high_resolution_clock::now();
	while ( fut1.wait_for(DELAY) != std::future_status::ready &&
		   std::chrono::high_resolution_clock::now() - start < DELAY )	{}
	std::cout << "TIME IS OUT\n ->>> START other THREAD...\n";
	
	std::cout << " ->>> Wait 5s ...";
	start = std::chrono::high_resolution_clock::now();
	while ( fut2.wait_until(std::chrono::high_resolution_clock::now() + 5s) != std::future_status::ready &&
		   std::chrono::high_resolution_clock::now() - start < DELAY ) {}
	std::cout << " nothing happen.\n";
}

- (void)test_future_launch_deferred_with_check
{
	auto fut_a = std::async( std::launch::async,    doAsyncWork, "async"  , 300 );
	auto fut_d = std::async( std::launch::deferred, doAsyncWork, "defered", 100 );
	
	auto safe_wait = [](auto&& fut, std::string tag) {
		if ( fut.wait_for(0s) == std::future_status::deferred ) {
			std::cout << " ->>> call wait() to launch [" << tag << "] future ...\n";
			fut.wait();
		}else{
			std::cout << " ->>> wait_for(60s) [" << tag << "] future to done ...\n";
			while (fut.wait_for(60s) != std::future_status::ready) {};
			std::cout << " ->>> awake from sleep !!!\n";
		}
	};
	
	safe_wait(std::move(fut_a), "async");
	safe_wait(std::move(fut_d), "defered");
}

- (void)test_future_really_async
{
	auto fut1 = really_async( doAsyncWork, "RED:async",  50 );
	auto fut2 = really_async( doAsyncWork, "DOG:async", 100 );
	auto fut3 = really_async( doAsyncWork, "CAT:async", 500 );
}

- (void)test_thread_joinable
{
	std::thread pt( doPrepare, "CAT:thread", 100 );
	
	if ( false ) // false - terminte application
	{
		pt.join();
		std::thread wt( doWork, "DOG:thread", 100 );
		wt.join();
	}
	
	if (pt.joinable())
		pt.join();
}

- (void)test_ThreadRAII
{
	auto process = [](auto&& pt, bool con)
	{
		if (con)
		{
			pt.get().join();
			std::thread wt( doWork, "DOG:thread", 100 );
			wt.join();
		}
	};
	
	std::cout << " ->>> Condition FALSE : SKEEP WORK\n";
	process( ThreadRAII( std::thread( doPrepare, "CAT:thread", 100 ), ThreadRAII::DtorAction::join ), false );
	
	std::cout << std::endl;
	
	std::cout << " ->>> Condition TRUE : DO WORK\n";
	process( ThreadRAII( std::thread( doPrepare, "CAT:thread", 100 ), ThreadRAII::DtorAction::join ), true );
}

- (void)test_flag
{
	std::atomic<bool> go(false);
	
	auto react_to_vent = [&go](std::string&& tag)
	{
		std::string tag_out = " ->>> [" + tag + "] ";
		std::cout <<  tag_out + "WAIT NOTIFICATION\n";
		// wait for notification
		while (!go);
		
		// react to event (m is locked)
		std::cout <<  tag_out + "EVENT PROCESSING ...\n";
		std::this_thread::sleep_for(2s);
		std::cout <<  tag_out + "EVENT DONE\n";
		
		// ! CLOSE critical section - ( unlock mutex via lk's dtor )
	};
	
	auto cat = std::async( react_to_vent, "CAT" );
	auto dog = std::async( react_to_vent, "DOG" );
	auto mic = std::async( react_to_vent, "MIC" );
	
	go = true;
}

- (void)test_condition_variable
{
	std::condition_variable cv;
	std::mutex	m;
	
	bool go = false;
	
	auto react_to_vent = [&m, &cv, &go](std::string&& tag)
	{
		std::string tag_out = " ->>> [" + tag + "] ";
		
		std::cout << tag_out + "OPEN CS\n";
		
		// ! OPEN critical section - ( lock mutex )
		std::unique_lock<std::mutex> lk(m);
		
		std::cout <<  tag_out + "WAIT NOTIFICATION\n";
		
		// wait for notification
		cv.wait(lk, [&go]{return go;});
		
		// react to event (m is locked)
		std::cout <<  tag_out + "EVENT PROCESSING ...\n";
		std::this_thread::sleep_for(1s);
		std::cout <<  tag_out + "EVENT DONE\n";
		
		// ! CLOSE critical section - ( unlock mutex via lk's dtor )
	};
	
	auto cat = std::async( std::launch::async, react_to_vent, "CAT" );
	auto dog = std::async( std::launch::async, react_to_vent, "DOG" );
	auto mic = std::async( std::launch::async, react_to_vent, "MIC" );
	
	{
		std::this_thread::sleep_for(1s);
		std::cout << " ->>> GO -> TRUE\n";
		std::lock_guard<std::mutex> g(m);
		go = true;
	}
	
	std::this_thread::sleep_for(1s);
	std::cout << " ->>> NITIFY ALL -> START\n";
	cv.notify_all();
}

- (void)test_thread_sync_run
{
	std::promise<void> go;
	auto sf = go.get_future().share();
	
	auto doWork = []() {
		std::cout << " ->>>   WORK DONE.\n";
	};
	
	auto scheduler = [sf, &doWork](){
		sf.wait();
		doWork();
	};
	
	std::list<std::thread> ts;
	auto n = 50;
	
	std::cout << " ->>> LAUNCH THREADS ...\n";
	while (n--) ts.emplace_back( scheduler );
	
	while ( std::any_of(ts.begin(), ts.end(), [](auto& t){ return !t.joinable(); }) );
	std::cout << " ->>> ALL THREADS LAUNCHED.\n";
	
	std::this_thread::sleep_for(1s);
	std::cout << " ->>> DO WORK!\n";
	go.set_value();
	
	for ( auto& t : ts ) t.join();
	std::cout << " ->>> ALL THREADS DONE.\n";
}

@end

// MARK:-

int namedFunction(std::string fn, std::string tag, int timeOut)
{
	static auto const constexpr STEPS = 5;
	for (auto i=0; i<STEPS; ++i)
	{
		std::this_thread::sleep_for( std::chrono::duration<long long, std::milli>( timeOut ) );
		std::stringstream msg;
		msg << " ->>> " << fn << " [" << tag << "] ";
		i+1==STEPS ? msg << "DONE\n" : msg << 100*(1.0*(i+1)/STEPS) << "%\n";
		std::cout << msg.str();
	}
	
	return 0;
}


int doPrepare(std::string tag, int timeOut) {
	return namedFunction("doPrepare", tag, timeOut);
}
int doWork(std::string tag, int timeOut)  {
	return namedFunction("doWork", tag, timeOut);
}
int doAsyncWork(std::string tag, int timeOut)  {
	return namedFunction("doAsyncWork", tag, timeOut);
}


























