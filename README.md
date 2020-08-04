# motivation
With using Docker you do not need install all tools in your local machine.
If your company works with ECR on a AWS it gets easier to deploy your local environment use a Docker with pre installed tools.

To work with application or component required tools: git, bash, docker.
That tools are available for most popular OS: Linux, Mac, Windows.

The last frontier is to get access on AWS ECR.
That bash script provide required functional.

# usage
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret
./ecr_pass.sh us-east-1 | docker login --username AWS --password-stdin https://my_dkr_id.dkr.ecr.us-east-1.amazonaws.com
