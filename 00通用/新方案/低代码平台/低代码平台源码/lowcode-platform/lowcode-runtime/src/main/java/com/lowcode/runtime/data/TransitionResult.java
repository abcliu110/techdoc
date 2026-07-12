package com.lowcode.runtime.data;

/**
 * 状态流转结果。
 */
public record TransitionResult(String recordLid, String fromState, String toState) {}
