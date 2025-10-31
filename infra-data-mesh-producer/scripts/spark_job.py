import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
import logging

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize Glue context
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

# Get job parameters
args = getResolvedOptions(sys.argv, ['JOB_NAME'])
job.init(args['JOB_NAME'], args)

logger.info("Starting Glue Spark Job")

try:
    # Create sample data to demonstrate Spark functionality
    logger.info("Creating sample DataFrame")
    
    # Create a sample DataFrame with some data
    sample_data = [
        ("Alice", 25, "Engineer", 75000),
        ("Bob", 30, "Manager", 85000),
        ("Charlie", 35, "Analyst", 65000),
        ("Diana", 28, "Engineer", 78000),
        ("Eve", 32, "Manager", 90000)
    ]
    
    columns = ["name", "age", "job", "salary"]
    df = spark.createDataFrame(sample_data, columns)
    
    logger.info(f"Created DataFrame with {df.count()} rows")
    df.show()
    
    # Perform some Spark transformations
    logger.info("Performing data transformations")
    
    # Filter employees with salary > 70000
    high_earners = df.filter(col("salary") > 70000)
    logger.info(f"High earners count: {high_earners.count()}")
    high_earners.show()
    
    # Group by job and calculate average salary
    avg_salary_by_job = df.groupBy("job").agg(
        avg("salary").alias("avg_salary"),
        count("*").alias("employee_count")
    )
    logger.info("Average salary by job:")
    avg_salary_by_job.show()
    
    # Calculate some statistics
    total_employees = df.count()
    avg_age = df.agg(avg("age")).collect()[0][0]
    avg_salary = df.agg(avg("salary")).collect()[0][0]
    
    logger.info(f"Total employees: {total_employees}")
    logger.info(f"Average age: {avg_age:.2f}")
    logger.info(f"Average salary: ${avg_salary:.2f}")
    
    # Create a simple aggregation
    summary_stats = df.agg(
        count("*").alias("total_employees"),
        avg("age").alias("avg_age"),
        avg("salary").alias("avg_salary"),
        min("salary").alias("min_salary"),
        max("salary").alias("max_salary")
    )
    
    logger.info("Summary statistics:")
    summary_stats.show()
    
    # Demonstrate Spark UI functionality (if enabled)
    if spark.conf.get("spark.ui.enabled", "false").lower() == "true":
        logger.info("Spark UI is enabled - you can monitor the job execution")
        logger.info("Spark UI will be available during job execution")
    else:
        logger.info("Spark UI is disabled")
    
    logger.info("Job completed successfully!")
    
except Exception as e:
    logger.error(f"Job failed with error: {str(e)}")
    raise e

finally:
    job.commit()

