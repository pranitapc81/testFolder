import re
import os
import pandas as pd
import ast
from datetime import datetime
from typing import List, Dict, Any, Tuple, Optional, Set
from api_client import APIClient  # Assuming this is a custom client class

PR_ID_PATTERN = re.compile(r'\bPR-\d+\b')

def ensure_directory_exists(directory: str) -> None:
    """Ensure the directory exists."""
    os.makedirs(directory, exist_ok=True)

def read_input_data(input_csv: str) -> pd.DataFrame:
    """Read and validate input data."""
    return pd.read_csv(input_csv)

def calculate_coverage(predicted: set, expected: set) -> float:
    print("predictedd", predicted)
    print("expected", expected)
    """Calculate coverage percentage."""
    if not expected:
        print("empty coberage")
        return 0.0
    correctly_predicted = len(predicted & expected)
    coverage = (correctly_predicted / len(expected)) * 100
    return coverage

def parse_expected_values(expected_raw: str) -> set:
    """Parse the expected values into a set."""
    try:
        if expected_raw.startswith('[') and expected_raw.endswith(']'):
            return set(ast.literal_eval(expected_raw))
        return set(expected_raw.split(','))
    except (ValueError, SyntaxError):
        return set(expected_raw.split(','))

def calculate_pr_coverage(predicted_raw: str, expected_raw: str) -> float:
    """Calculate PR coverage."""
    predicted = set(PR_ID_PATTERN.findall(predicted_raw or ''))
    expected = parse_expected_values(expected_raw)
    return calculate_coverage(predicted, expected)

def save_results_to_csv(results: List[Dict[str, Any]], output_dir: str) -> Tuple[str, pd.DataFrame]:
    """Save results to a CSV file."""
    timestamp = datetime.now().strftime('%d%m%Y_%H%M')
    output_file = os.path.join(output_dir, f'Evaluation_Result_{timestamp}.csv')
    output_dataframe = pd.DataFrame(results)
    output_dataframe.to_csv(output_file, index=False)
    return output_file, output_dataframe

def process_direct_answer(response: dict, row: pd.Series) -> Dict[str, Any]:
    """Process direct answer results."""
    # Process Jira IDs by splitting on both semicolons and commas
    def process_jira_ids(ids_str):
        print("----------------fq------", ids_str)
        if not ids_str:
            print("empty")
            return set()
        # Replace semicolons with commas and split
        jira_ids = set(ids_str.replace(';', ',').split(','))
        print("----------------f------", jira_ids)
        return jira_ids
    
    print("checkkkk123")
    # Get the predicted JIRA IDs as a string and split into a set
    predicted_jira_str = response.get('Predicted Interpretation Jira', '')
    predicted_jira_set = set(predicted_jira_str.split(',')) if predicted_jira_str else set()
    
    interpretation_jira_coverage = calculate_coverage(
        predicted_jira_set,
        process_jira_ids(row.get('Expected Interpretation Jira'))
    )

    print("----------------dd--", interpretation_jira_coverage)

    # Handle jira_ids_analyzed as a comma-separated string
    jira_analyzed_str = str(response.get('jira_ids_analyzed', '')) or ''
    jira_analyzed_set = set(jira_analyzed_str.split(',')) if jira_analyzed_str else set()
    
    jira_coverage = calculate_coverage(
        jira_analyzed_set,
        process_jira_ids(row.get(key='Expected Jira ID Analyzed', default=''))
    )
    direct_answer_performance_score = (interpretation_jira_coverage + jira_coverage) / 2


    print("----------------ddd--", row.get('Expected Interpretation Jira'))

    

    return {
        "Direct Answer Performance Score": direct_answer_performance_score,
        "Direct Answer Status": direct_answer_performance_score >= 80,
        "Predicted Interpretation Jira": ''.join(response.get("Predicted Interpretation Jira", [])),
        "Expected Interpretation Jira": row.get('Expected Interpretation Jira'),
        "Interpretation Jira Coverage": interpretation_jira_coverage,
    }

def process_implementation_answer(response: dict, row: pd.Series) -> Dict[str, Any]:
    """Process implementation answer results."""
    implementation_jira_coverage = calculate_coverage(
        set(response.get('Predicted Implementation Jira', [])),
        set(row.get(key='Expected Implementation Jira', default='').split(','))
    )
    pr_coverage = calculate_pr_coverage(
        response.get('Predicted Implementation PR', ''),
        row.get(key='Expected Implementation PR', default='')
    )

    return {
        "Predicted Implementation Jira": response.get("Predicted Implementation Jira", []),
        "Expected Implementation Jira": row.get('Expected Implementation Jira'),
        "Implementation Jira Coverage": implementation_jira_coverage,
        "Predicted Implementation PR": response.get("Predicted Implementation PR", []),
        "Expected Implementation PR": row.get('Expected Implementation PR'),
        "Implementation PR Coverage": pr_coverage,
    }

async def process_row(row: pd.Series, client: APIClient, result_type: str) -> Optional[Dict[str, Any]]:
    """Process a single row of input data."""
    try:
        question = row.get('Question')
        answer_mode = row.get('Answer Mode')

        if not question or not answer_mode:
            raise ValueError("'Question' or 'Answer Mode' is missing.")

        response = await client.call(question, answer_mode)

        result = {
            "Scenario": row.get('Scenario'),
            "Question": row.get('Question'),
            "Predicted Answer": response.get('answer'),
            "Expected Answer": row.get('Expected Answer'),
            "Predicted Jira ID Analyzed": response.get('jira_ids_analyzed'),
            "Expected Jira ID Analyzed": row.get('Expected Jira ID Analyzed'),
            "Jira Coverage": calculate_coverage(
                set(str(response.get('jira_ids_analyzed', '')).split(',')),
                set(row.get('Expected Jira ID Analyzed', '').split(','))
            ),
        }

        if result_type == 'direct_answer':
            result.update(process_direct_answer(response, row))
        elif result_type == 'implementation_answer':
            result.update(process_implementation_answer(response, row))

        return result

    except Exception as e:
        raise e


async def run_regression(input_csv: str, output_dir: str, client: APIClient, result_type: str, runs: int = 4) -> Tuple[str, pd.DataFrame]:
    """Run the regression process."""
    try:
        ensure_directory_exists(output_dir)
        data = read_input_data(input_csv)

        results = []

        for run_id in range(1, runs + 1):
            for _, row in data.iterrows():
                print("row---", row)
                print("rowe", row.get('Expected Interpretation Jira'))
                result = await process_row(row, client, result_type)
                if result:
                    result["Run"] = run_id
                    results.append(result)
        
        results.sort(key=lambda x: x["Scenario"])
        return save_results_to_csv(results, output_dir)

    except Exception as e:
        print(f"Error in run_regression: {e}")
        raise
