pushd

hl profiler.hl ../hlprofile.dump --out profile.json
:: To detect spikes, add:
:: --min-time-ms 20
popd