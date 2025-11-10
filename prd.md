we need to build a demo for cloud rewind
specs in initial-spec.md
create plans, progress first under /plans
put docs, architectures,  and readme under /docs
list down resources to be written in with their spec so its clear when building time
make sure resources connect by validating networking (just by cfn)
ec2 no need fo rssh just use SSM to login if debug is needed
put all passwords in cfn output 
split plans so its easy to track
i just want 1 cfn to run in singapore
i will put AWS credentials in environment variable for easy test
Build first test second