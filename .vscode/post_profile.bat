@echo off
IF NOT "%1"== "" (
	hl tools/profiler.hl /u %1
) ELSE (
	hl tools/profiler.hl
)
