// Code generated by counterfeiter. DO NOT EDIT.
package enginefakes

import (
	"context"
	"sync"

	"code.cloudfoundry.org/lager"
	"github.com/concourse/concourse/atc/db"
	"github.com/concourse/concourse/atc/engine"
)

type FakeEngine struct {
	NewBuildStub        func(db.Build) engine.Runnable
	newBuildMutex       sync.RWMutex
	newBuildArgsForCall []struct {
		arg1 db.Build
	}
	newBuildReturns struct {
		result1 engine.Runnable
	}
	newBuildReturnsOnCall map[int]struct {
		result1 engine.Runnable
	}
	NewCheckStub        func(context.Context, db.Check) engine.Runnable
	newCheckMutex       sync.RWMutex
	newCheckArgsForCall []struct {
		arg1 context.Context
		arg2 db.Check
	}
	newCheckReturns struct {
		result1 engine.Runnable
	}
	newCheckReturnsOnCall map[int]struct {
		result1 engine.Runnable
	}
	ReleaseAllStub        func(lager.Logger)
	releaseAllMutex       sync.RWMutex
	releaseAllArgsForCall []struct {
		arg1 lager.Logger
	}
	invocations      map[string][][]interface{}
	invocationsMutex sync.RWMutex
}

func (fake *FakeEngine) NewBuild(arg1 db.Build) engine.Runnable {
	fake.newBuildMutex.Lock()
	ret, specificReturn := fake.newBuildReturnsOnCall[len(fake.newBuildArgsForCall)]
	fake.newBuildArgsForCall = append(fake.newBuildArgsForCall, struct {
		arg1 db.Build
	}{arg1})
	fake.recordInvocation("NewBuild", []interface{}{arg1})
	fake.newBuildMutex.Unlock()
	if fake.NewBuildStub != nil {
		return fake.NewBuildStub(arg1)
	}
	if specificReturn {
		return ret.result1
	}
	fakeReturns := fake.newBuildReturns
	return fakeReturns.result1
}

func (fake *FakeEngine) NewBuildCallCount() int {
	fake.newBuildMutex.RLock()
	defer fake.newBuildMutex.RUnlock()
	return len(fake.newBuildArgsForCall)
}

func (fake *FakeEngine) NewBuildCalls(stub func(db.Build) engine.Runnable) {
	fake.newBuildMutex.Lock()
	defer fake.newBuildMutex.Unlock()
	fake.NewBuildStub = stub
}

func (fake *FakeEngine) NewBuildArgsForCall(i int) db.Build {
	fake.newBuildMutex.RLock()
	defer fake.newBuildMutex.RUnlock()
	argsForCall := fake.newBuildArgsForCall[i]
	return argsForCall.arg1
}

func (fake *FakeEngine) NewBuildReturns(result1 engine.Runnable) {
	fake.newBuildMutex.Lock()
	defer fake.newBuildMutex.Unlock()
	fake.NewBuildStub = nil
	fake.newBuildReturns = struct {
		result1 engine.Runnable
	}{result1}
}

func (fake *FakeEngine) NewBuildReturnsOnCall(i int, result1 engine.Runnable) {
	fake.newBuildMutex.Lock()
	defer fake.newBuildMutex.Unlock()
	fake.NewBuildStub = nil
	if fake.newBuildReturnsOnCall == nil {
		fake.newBuildReturnsOnCall = make(map[int]struct {
			result1 engine.Runnable
		})
	}
	fake.newBuildReturnsOnCall[i] = struct {
		result1 engine.Runnable
	}{result1}
}

func (fake *FakeEngine) NewCheck(arg1 context.Context, arg2 db.Check) engine.Runnable {
	fake.newCheckMutex.Lock()
	ret, specificReturn := fake.newCheckReturnsOnCall[len(fake.newCheckArgsForCall)]
	fake.newCheckArgsForCall = append(fake.newCheckArgsForCall, struct {
		arg1 context.Context
		arg2 db.Check
	}{arg1, arg2})
	fake.recordInvocation("NewCheck", []interface{}{arg1, arg2})
	fake.newCheckMutex.Unlock()
	if fake.NewCheckStub != nil {
		return fake.NewCheckStub(arg1, arg2)
	}
	if specificReturn {
		return ret.result1
	}
	fakeReturns := fake.newCheckReturns
	return fakeReturns.result1
}

func (fake *FakeEngine) NewCheckCallCount() int {
	fake.newCheckMutex.RLock()
	defer fake.newCheckMutex.RUnlock()
	return len(fake.newCheckArgsForCall)
}

func (fake *FakeEngine) NewCheckCalls(stub func(context.Context, db.Check) engine.Runnable) {
	fake.newCheckMutex.Lock()
	defer fake.newCheckMutex.Unlock()
	fake.NewCheckStub = stub
}

func (fake *FakeEngine) NewCheckArgsForCall(i int) (context.Context, db.Check) {
	fake.newCheckMutex.RLock()
	defer fake.newCheckMutex.RUnlock()
	argsForCall := fake.newCheckArgsForCall[i]
	return argsForCall.arg1, argsForCall.arg2
}

func (fake *FakeEngine) NewCheckReturns(result1 engine.Runnable) {
	fake.newCheckMutex.Lock()
	defer fake.newCheckMutex.Unlock()
	fake.NewCheckStub = nil
	fake.newCheckReturns = struct {
		result1 engine.Runnable
	}{result1}
}

func (fake *FakeEngine) NewCheckReturnsOnCall(i int, result1 engine.Runnable) {
	fake.newCheckMutex.Lock()
	defer fake.newCheckMutex.Unlock()
	fake.NewCheckStub = nil
	if fake.newCheckReturnsOnCall == nil {
		fake.newCheckReturnsOnCall = make(map[int]struct {
			result1 engine.Runnable
		})
	}
	fake.newCheckReturnsOnCall[i] = struct {
		result1 engine.Runnable
	}{result1}
}

func (fake *FakeEngine) ReleaseAll(arg1 lager.Logger) {
	fake.releaseAllMutex.Lock()
	fake.releaseAllArgsForCall = append(fake.releaseAllArgsForCall, struct {
		arg1 lager.Logger
	}{arg1})
	fake.recordInvocation("ReleaseAll", []interface{}{arg1})
	fake.releaseAllMutex.Unlock()
	if fake.ReleaseAllStub != nil {
		fake.ReleaseAllStub(arg1)
	}
}

func (fake *FakeEngine) ReleaseAllCallCount() int {
	fake.releaseAllMutex.RLock()
	defer fake.releaseAllMutex.RUnlock()
	return len(fake.releaseAllArgsForCall)
}

func (fake *FakeEngine) ReleaseAllCalls(stub func(lager.Logger)) {
	fake.releaseAllMutex.Lock()
	defer fake.releaseAllMutex.Unlock()
	fake.ReleaseAllStub = stub
}

func (fake *FakeEngine) ReleaseAllArgsForCall(i int) lager.Logger {
	fake.releaseAllMutex.RLock()
	defer fake.releaseAllMutex.RUnlock()
	argsForCall := fake.releaseAllArgsForCall[i]
	return argsForCall.arg1
}

func (fake *FakeEngine) Invocations() map[string][][]interface{} {
	fake.invocationsMutex.RLock()
	defer fake.invocationsMutex.RUnlock()
	fake.newBuildMutex.RLock()
	defer fake.newBuildMutex.RUnlock()
	fake.newCheckMutex.RLock()
	defer fake.newCheckMutex.RUnlock()
	fake.releaseAllMutex.RLock()
	defer fake.releaseAllMutex.RUnlock()
	copiedInvocations := map[string][][]interface{}{}
	for key, value := range fake.invocations {
		copiedInvocations[key] = value
	}
	return copiedInvocations
}

func (fake *FakeEngine) recordInvocation(key string, args []interface{}) {
	fake.invocationsMutex.Lock()
	defer fake.invocationsMutex.Unlock()
	if fake.invocations == nil {
		fake.invocations = map[string][][]interface{}{}
	}
	if fake.invocations[key] == nil {
		fake.invocations[key] = [][]interface{}{}
	}
	fake.invocations[key] = append(fake.invocations[key], args)
}

var _ engine.Engine = new(FakeEngine)
